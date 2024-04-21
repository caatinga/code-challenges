# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import std/[files, paths, terminal, strformat, sequtils]
import toml_serialization
import nimword

const hashIterations: int = 10_199
const mainVault: string = "./data/"
const welcome: string = "Welcome to Nim Vault - The best password manager"
const options: string = """

What would you like to do?

1. Create a new password vault?
2. Sign in to a password vault
3. Add a password to a vault
4. Fetch a password from a vault

Quit (enter q or quit)
"""

type
  Record = object
    name: string
    username: string
    password: string

  Vault = object
    records: seq[Record]
    master_password: string


when isMainModule:
  echo welcome

  var
    activated_vault: Option[Vault]
    activated_vault_file: string

  while true:
    echo options
    case readLine(stdin)
    of "q", "quit":
      echo "leaving..."
      break
    of "1":
      var 
        name: string
        master_password: string
        confirm_password: string

      echo "Creating a new vault..."
      echo "Please provide a name for the vault:"
      name = readLine(stdin)

      master_password = readPasswordFromStdin("Please enter a master password:")
      confirm_password = readPasswordFromStdin("Please confirm the master password:")
      if master_password != confirm_password:
        echo "please, check if the all password's are correct"
        continue

      let master_hashed_password = hashEncodePassword(master_password, hashIterations, NimwordHashingAlgorithm.nhaPbkdf2Sha256)
      var filename = mainVault & name & ".vvv" 
      var toml_vault = Toml.encode(Vault(master_password: master_hashed_password))
      writeFile(filename, toml_vault)
      echo "New vault created and saved as: ", filename

    of "2":
      var 
        vault_file: Vault
        vault_name: string
        password: string
        filename: string

      echo "Enter vault name:"
      discard readLine(stdin, vault_name)

      filename = &"{mainVault}{vault_name}.vvv"
      if not fileExists(Path(filename)):
        echo &"{filename} not found"
        continue

      vault_file = Toml.loadFile(filename, Vault)
      while not password.isValidPassword(vault_file.master_password):
        let prompt = &"Enter a password for {vault_name} vault: "
        discard readPasswordFromStdin(prompt, password)

      activated_vault = some(vault_file)
      activated_vault_file = filename
      echo "Thank you, you are now signed in..."

    of "3":
      var
        name: string
        username: string
        password: string

      if activated_vault.isNone():
        echo "Please, sign in to a vault"
        continue

      echo "Record name:"
      discard readLine(stdin, name)

      echo "Username:"
      discard readLine(stdin, username)

      discard readPasswordFromStdin("Password: ", password)

      let new_record = Record(name: name, username: username, password: password)
      var vault = activated_vault.get()
      vault.records.add(new_record)

      writeFile(activated_vault_file, Toml.encode(vault))
      echo "saved!"

    of "4":
      if activated_vault.isNone():
        echo "Please, sign in to a vault"
        continue

      var
        record_name: string
        vault = activated_vault.get()

      echo "Fetching password"
      echo "Please enter the record name:"
      discard readLine(stdin, record_name)

      let
        found = filter(
          vault.records,
          proc(r: Record): bool = r.name == record_name
        )

      if len(found) == 0:
        echo &"Record {record_name} not found"
        continue

      echo ""
      echo &"For {record_name} record"
      echo &"The username is {found[0].username}"
      echo &"The password is {found[0].password}"
