#!/bin/bash

# Import test_lib and the script to be tested
source ../security/security.sh

function preTest(){        
    original_kdlsec_public_key=${KDLSEC_MASTER_KEY:-}
    test_keychain_file="test_keychain.kc"
    test_password="TestPassword123"
}

function testCheckMasterKey(){    
    export KDLSEC_MASTER_KEY="TestMasterKey123"
    if checkMasterKey; then
        return 0
    else
        return 1
    fi

}

function testCreateKeychain(){    
    createKeychain "$test_keychain_file" "$KDLSEC_MASTER_KEY"
    if [ -e "$test_keychain_file" ]; then
        return 0
    else
        return 1
    fi
}

function testOpenKeychain(){    
    openKeychain "$test_keychain_file" "$KDLSEC_MASTER_KEY"
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

function testEncryptPassword(){    
    local encrypted_password
    encrypted_password=$(encryptPassword "$test_password" "$KDLSEC_MASTER_KEY")
    if [ ! -z "$encrypted_password" ]; then
        return 0
    else
        return 1
    fi
}

function testGeneratePrivateKey(){    
    local private_key
    private_key=$(generatePrivateKey)
    if [ ! -z "$private_key" ]; then
        return 0
    else
        return 1
    fi
}

function testStorePasswordInKeychain(){    
    local returned_key
    returned_key=$(storePasswordInKeychain "$test_password" "$test_keychain_file" "$KDLSEC_MASTER_KEY")
    # Check if a non-empty key is returned
    if [ ! -z "$returned_key" ]; then
        return 0
    else
        return 1
    fi
}

function testDecryptPassword(){    
    local encryption_key
    encryption_key=$(generatePrivateKey)
    local encrypted_password
    encrypted_password=$(encryptPassword "$test_password" "$encryption_key")
    local decrypted_password
    decrypted_password=$(decryptPassword "$encrypted_password" "$encryption_key")
    # Check if the decrypted password matches the original
    if [ "$decrypted_password" == "$test_password" ]; then
        return 0
    else
        return 1
    fi
}

function testRetrievePasswordFromKeychain(){    
    local encryption_key
    encryption_key=$(storePasswordInKeychain "$test_password" "$test_keychain_file" "$KDLSEC_MASTER_KEY")    
    local retrieved_password
    retrieved_password=$(retrievePasswordFromKeychain "$encryption_key" "$test_keychain_file" "$KDLSEC_MASTER_KEY")    
    
    # Check if the retrieved password matches the original
    if [ "$retrieved_password" == "$test_password" ]; then
        return 0
    else
        return 1
    fi
}

function testVerifyKeychainEncryption(){    
    if verifyKeychainEncryption "$test_keychain_file" "$KDLSEC_MASTER_KEY"; then
        return 0
    else
        return 1
    fi
}

function postTest(){
    echo "Tests for the security.sh script completed."

    # Cleanup: Removing test keychain file
    rm "$test_keychain_file"    
    # Restore KDLSEC_MASTER_KEY to its original value or unset if it was not set before
    ([ -n "$original_kdlsec_public_key" ] && export KDLSEC_MASTER_KEY="$original_kdlsec_public_key") || unset KDLSEC_MASTER_KEY
    
    unset test_keychain_file test_password    
    
    echo "All tests completed."
}

function run(){
    source test_lib.sh
    preTest
    runAllTests
    postTest
}

run