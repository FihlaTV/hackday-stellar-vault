use_manual_close

account :scott, Stellar::KeyPair.from_seed("s3AnFq5uyGoHqTsSzV3Dpk2RM1tQmg9b9GEMgVGKzGc9Tu4Z1pT")

create_account :scott

close_ledger

add_signer :scott, Stellar::KeyPair.from_seed("s3G7WDNuXboNTE2y7YVZykpy9WnDKGNz9vDTG5xnxwBpg2T1LnQ"), 1
add_signer :scott, Stellar::KeyPair.from_seed("sfQZuVzpDzb8YvQE1ic8zb6gAgHFftFK57VJzom2tUnbDZDWygh"), 1
set_thresholds :scott, master_weight: 1, low: 0, medium: 2, high: 2
