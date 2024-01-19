#! /usr/bin/bash
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


cd "$(dirname "$0")"

# add local variables to scope
source .env

echo -e "${YELLOW}deply Cutrix${NC}"
forge create --rpc-url http://127.0.0.1:8545/ --private-key $PRIVATE_KEY_ANVIL src/Cutrix.sol:Cutrix 
# forge script script/Cutrix.s.sol:CutrixScript --rpc-url http://127.0.0.1:8545/ 
