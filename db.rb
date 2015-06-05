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

  def add_signature!(seed)
    signer = Stellar::KeyPair.from_seed(seed)
    dsig   = tx.sign_decorated(signer)

    self.signatures << dsig.to_xdr(:hex)
    save!
  end

  def address_from_hint(hint)
    possibles = [tx.source_account]
    possibles += tx.operations.map(&:source_account).compact

    found = possibles.find{|pk| pk[0...4] == hint }

    Stellar::Convert.pk_to_address(found)
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
end

class TransactionHistory < Core::Base
  self.table_name = "txhistory"
end
