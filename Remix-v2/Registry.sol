// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./ENSNamehash.sol";

contract Registry {
    using ENSNamehash for bytes;
    
    struct NodeRecord {
        string id;
        address nftcontract;
    }
    struct ThemeRecord {
        address publisher;
    }
    struct SystemRecord {
        address locationNFTContract;
        address questNFTContract;
        address regionsNFTContract;
        address charactersNFTContract;
        address itemsNFTContract;
        address loreNFTContract;
    }
    
    mapping(bytes32 => string) namehashToType;
    mapping(bytes32 => NodeRecord) nodeRecords;
    mapping(bytes32 => SystemRecord) systemRecords;
    mapping(bytes32 => ThemeRecord) themeRecords;
    
    
    constructor() {}

    function getNamehash(bytes memory name) public pure returns (bytes32) {
        return name.namehash();
    }
    
    function registerSystem(bytes memory name) public {
        bytes32 nh = name.namehash();
        namehashToType[nh] = 'system';
        systemRecords[nh] = SystemRecord(address(0x0), address(0x0), address(0x0), address(0x0), address(0x0), address(0x0));
    }
    
    function updateSystem(bytes memory name, string memory contractType, address contractAddress) public {
        bytes32 nh = name.namehash();
        if(compareStrings(contractType, "location")){
            systemRecords[nh].locationNFTContract = contractAddress;
        }
    }
    
    function compareStrings(string memory s1, string memory s2) public pure returns (bool) {
        return keccak256(abi.encodePacked((s1))) == keccak256(abi.encodePacked((s2)));
    }
    
    function resolveSystemNamehash(bytes memory name) public view returns (SystemRecord memory) {
        bytes32 nh = name.namehash();
        return systemRecords[nh];  
    }
    
    function resolveThemeNamehash(bytes memory name) public view returns (ThemeRecord memory) {
        bytes32 nh = name.namehash();
        return themeRecords[nh];  
    }
    
    function resolveNodeNamehash(bytes memory name) public view returns (NodeRecord memory) {
        bytes32 nh = name.namehash();
        return nodeRecords[nh];
    }

    function registerTheme(bytes memory name, address pubAddress) public {
      bytes32 nh = name.namehash();
      namehashToType[nh] = "theme";
      themeRecords[nh] = ThemeRecord(pubAddress);
    }

    function updateTheme(bytes memory name, address pubAddress) public {
      bytes32 nh = name.namehash();
      themeRecords[nh].publisher = pubAddress;
    }

    function resolveNamehashType(bytes memory name) public returns (string memory) {
      return namehashToType[name.namehash()];
    }


    /*
    function resolveNamehash(bytes memory name) public view returns (address) {
        //always resolve to a resolver contract, which will return appropriate data 
        // for nft.nftcontract all the nfts should be resolved to the nftcontract address and let that address return information about the nft
        return contracts[name.namehash()];
    }
    
    function setNamehashContract(bytes memory name, address contractAddress) public {
        contracts[name.namehash()] = contractAddress;
    } 
    */
    
}
