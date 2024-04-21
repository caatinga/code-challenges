# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import std/terminal
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
        password_checked: bool

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

