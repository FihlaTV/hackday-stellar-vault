require 'active_record'

raise "No DATABASE_URL" if ENV["DATABASE_URL"].blank?
raise "No STELLAR_CORE_DATABASE_URL" if ENV["STELLAR_CORE_DATABASE_URL"].blank?


module Vault
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection(ENV["DATABASE_URL"])
  end
end

module Core
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection(ENV["STELLAR_CORE_DATABASE_URL"])
  end
end

class Transaction < Vault::Base
  extend Memoist

  validates :hash_hex, presence: true, uniqueness: true
  validates :tx_hex, presence: true

  # serialized array of hex-encoded signatures
  serialize :signatures, Array

  memoize def tx
    raw = Stellar::Convert.from_hex(tx_hex)
    Stellar::Transaction.from_xdr raw
  end

  def operations
    tx.operations
  end

  def source_account(op)
    account = op.source_account
    account ||= tx.source_account

    Stellar::Convert.pk_to_address(account)
  end

  def add_any_available_signatures!
    protected_keys, unprotected_keys = Key.
      where(address:possible_signers).
      partition(&:needs_verification?)

    # TODO: issue challenges for any keys that need them

    unprotected_keys.each do |key|
      add_signature! key.seed
    end
  end

  def add_signature!(seed)
    signer = Stellar::KeyPair.from_seed(seed)
    dsig   = tx.sign_decorated(signer)

    self.signatures << dsig.to_xdr(:hex)
    self.signatures.uniq!
    save!
  end

  def address_from_hint(hint)
    possibles = [tx.source_account]
    possibles += tx.operations.map(&:source_account).compact

    possible_signers.find do |possible|
      kp = Stellar::KeyPair.from_address(possible)
      kp.public_key_hint == hint
    end
  end

  def possible_signers
    possible_accounts = [Stellar::Convert.pk_to_address(tx.source_account)]
    possible_accounts += tx.operations.map(&:source_account).compact

    possible_accounts.
      map{|a| Account.key_addresses(a)}.
      flatten.
      uniq
  end

  def envelope_hex
    txe            = Stellar::TransactionEnvelope.new
    txe.tx         = self.tx
    txe.signatures = decoded_signatures

    txe.to_xdr(:hex)
  end

  def hash_hex
    Stellar::Convert.to_hex tx.hash
  end

  def submit!
    raw_resp = Core::Web.get(path:"/tx", query:{blob: envelope_hex})
    json_resp = ActiveSupport::JSON.decode(raw_resp.body)

    if json_resp["exception"].present?
      raise json_resp["exception"]
    end

    case json_resp["status"]
    when "PENDING", "DUPLICATE"
      return
    when "ERROR"
      return json_resp["error"]
    else
      raise "Unknown status: #{json_resp["status"]}"
    end
  end

  def submit_if_possible
    return [:not_done, nil] unless done?

    error = submit!

    # we errored
    return [:error, error] if error.present?

    wait_for_consensus
    return [:submitted, nil]
  end

  def result
    row = TransactionHistory.where(txid:hash_hex).first
    return if row.blank?

    raw  = Stellar::Convert.from_base64 row.txresult
    pair = Stellar::TransactionResultPair.from_xdr(raw)
    pair.result
  end

  def result_summary
    r = result

    return {status: :success} if r.result.switch == Stellar::TransactionResultCode.tx_success

    result = {status: :failed}
    result[:operations] = r.result.results!.map{|opr| opr.tr!.value.code.name}
    result
  end

  def wait_for_consensus
    Timeout.timeout(30.seconds) do
      loop do
        break if result.present?
        sleep 1.0
      end
    end
  end

  memoize def decoded_signatures
    signatures.map do |sig_hex|
      Stellar::DecoratedSignature.from_xdr(Stellar::Convert.from_hex(sig_hex))
    end
  end

  def done?
    operation_summary.each do |os|
      return false if os[:has] < os[:needs]
    end

    return true
  end

  def operation_summary
    tx.operations.map do |op|
      {}.tap do |summary|
        sa_addy = source_account(op)
        sa = Account.where(accountid: sa_addy).first

        raise "couldn't find account: #{sa_addy}" if sa.blank?


        summary[:type]    = op.body.switch
        summary[:account] = sa_addy
        summary[:needs]   = sa.threshold_for_op op
        summary[:has]     = decoded_signatures.map{|da| sa.weight_for_sig(da)}.sum


      end
    end
  end

end

class TransactionHistory < Core::Base
  self.table_name = "txhistory"
end


class Signer < Core::Base
  self.table_name = "signers"

  def address
    publickey
  end
end

class Account < Core::Base
  self.table_name = "accounts"
  self.primary_key = "accountid"

  has_many :signers, foreign_key: 'accountid'

  def self.key_addresses(addy)
    sa = Account.where(accountid: addy).first
    raise "couldn't find account: #{addy}" if sa.blank?

    sa.signer_addresses
  end

  def signer_addresses
    signers.map(&:publickey) + [accountid]
  end

  def address_from_hint(hint)
    signer_addresses.find do |possible|
      kp = Stellar::KeyPair.from_address(possible)
      kp.public_key_hint == hint
    end
  end

  def thresholds
    hex = attributes['thresholds']
    raw = Stellar::Convert.from_hex hex
    {
      low:    raw[1].unpack("C").first,
      medium: raw[2].unpack("C").first,
      high:   raw[3].unpack("C").first,
    }
  end

  def master_weight
    hex = attributes['thresholds']
    raw = Stellar::Convert.from_hex hex
    raw[0].unpack("C").first
  end

  def key_weights
    {}.tap do |result|
      result[accountid] = master_weight

      signers.each do |s|
        result[s.address] = s.weight
      end
    end
  end

  def threshold_for_op(op)
    type = op.body.switch

    case type
    when Stellar::OperationType.allow_trust
      thresholds[:low]
    when Stellar::OperationType.set_options
      soop = op.body.set_options_op!
      level = :medium

      level = :high if soop.signer.present?
      level = :high if soop.thresholds.present?

      thresholds[:level]
    else
      thresholds[:medium]
    end
  end

  def weight_for_sig(da)
    address = address_from_hint(da.hint)
    key_weights.fetch(address, 0)
  end
end

#
# Key is a key stored on behalf of someone elses account
#
# Vault will search it's database for needed keys when a transaction is submitted
class Key < Vault::Base
  extend Memoist
  validates :address, presence: true
  validates :seed, presence: true

  serialize :validator

  before_validation :populate

  def populate
    return if keypair.blank?
    self.address = keypair.address
  end

  def needs_verification?
    #TODO
    false
  end

  memoize def keypair
    return nil if seed.blank?
    Stellar::KeyPair.from_seed seed
  rescue ArgumentError
    errors.add(:seed, "is not valid")
    return nil
  end
end
