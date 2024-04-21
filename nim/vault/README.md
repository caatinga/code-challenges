# Vault - Nim version

Building a cli version of a password manager

1. Create a password vault.
2. Sign in to an existing password vault.
3. Create a password record within a vault.
4. Retrieve a password record and the associated password from a vault.

```toml
[[records]]
  name = "google account"
  username = "my@email.com"
  password = "ohmygoshmypwd"

[[records]]
  name = "github"
  username = "lolzinnho"
  password = "maoeu"

master_password = "$pbkdf2_sha256$10199$zrRIPBmBnpzgBcoZXfFi7A$EORf49mr+1nqF/s0gmSm5NqRmFDFOgPmUruHDtPATrU"
```
