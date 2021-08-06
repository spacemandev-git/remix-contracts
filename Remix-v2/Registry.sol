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
    struct BlueprintData {
        string assetname;
        string imageURL;
        string description;
        uint cost;
        bytes32[] dependencies;
        uint[] quantities;
    }
    /*
    struct TokenQuantity {
        bytes32 tokenHash;
        uint quantity;
    }
    */
    struct NFTOwner {
        mapping(bytes32 => uint) quantity;
    }
    struct NFTData {
        string assetname;
        string imageURL;
        string description;
    }
    
    mapping(bytes32 => string) namehashToType;
    mapping(bytes32 => NodeRecord) nodeRecords;
    mapping(bytes32 => SystemRecord) systemRecords;
    mapping(bytes32 => ThemeRecord) themeRecords;
    mapping(address => NFTOwner) nftOwners;
    mapping(bytes32 => NFTData) nftData;
    mapping(bytes32 => address) blueprintOwners;
    mapping(bytes32 => BlueprintData) blueprintData;
    // mapping(bytes32 => TokenQuantity) 
    // uint [] tokenQuantity;
    
    
    constructor() {}

    /*
    function getNamehash(bytes memory name) public pure returns (bytes32) {
        return name.namehash();
        nftname.nft-type.theme.universe.system.rem
    }
    */
    
    function getNamehash(bytes memory name) public view returns (bytes32) {
        return name.namehash();
    }
    
    function registerSystem(string memory name) public {
        bytes32 nh = bytes(name).namehash();
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
    
    function resolveSystemNamehash(string memory name) public view returns (SystemRecord memory) {
        bytes32 nh = bytes(name).namehash();
        return systemRecords[nh];  
    }
    
    function resolveThemeNamehash(string memory name) public view returns (ThemeRecord memory) {
        bytes32 nh = bytes(name).namehash();
        return themeRecords[nh];
    }
    
    function resolveNodeNamehash(string memory name) public view returns (NodeRecord memory) {
        bytes32 nh = bytes(name).namehash();
        return nodeRecords[nh];
    }

    function registerTheme(string memory name, address pubAddress) public payable {
      require(msg.value == 1 ether, "It costs 1 ETH to purchase a Universe");
      bytes32 nh = bytes(name).namehash();
      namehashToType[nh] = "theme";
      themeRecords[nh] = ThemeRecord(pubAddress);
    }

    function updateTheme(string memory name, address pubAddress) public {
      bytes32 nh = bytes(name).namehash();
      themeRecords[nh].publisher = pubAddress;
    }
    
    /*
    function resolveNamehashType(string memory name) public returns (string memory) {
      return namehashToType[bytes(name).namehash()];
    }
    */
    
    function createBlueprint(string memory assetURI, string memory assetname, string memory imageURL, string memory description, uint cost) public {
        bytes32 blueprintTokenId = bytes(assetURI).namehash();
        require(blueprintOwners[blueprintTokenId] != address(0));
        blueprintOwners[blueprintTokenId] = msg.sender;
        bytes32[] memory tokenHashes;
        uint[] memory quantities; 
        blueprintData[blueprintTokenId] = BlueprintData({assetname: assetname, imageURL: imageURL, description: description, cost: cost, dependencies: tokenHashes, quantities: quantities});
    }
    
    function updateBlueprint(string memory assetURI, uint quantity) public {
        bytes32 assetURInh = bytes(assetURI).namehash();
        require(msg.sender == blueprintOwners[assetURInh]);
        blueprintData[assetURInh].dependencies.push(assetURInh);
        blueprintData[assetURInh].quantities.push(quantity);
    }
    
    function checkDependency(bytes32[] memory dependencies, uint[] memory quantities, address sender, uint value) public view returns (bool) {
        uint numDependencies = dependencies.length;
        uint cost;
        for (uint i=0; i<numDependencies; i++) {
            bytes32 assetURI = dependencies[i];
            uint quantity = quantities[i];
            if (nftOwners[sender].quantity[assetURI] != quantity) {
                return false;
            }
            cost += blueprintData[assetURI].cost;
        }
        if (cost != value) {
            return false;
        }
        return true;
    }
    
    function mint(string memory assetURI) public payable {
        bytes32 assetURInh = bytes(assetURI).namehash();
        require(checkDependency(blueprintData[assetURInh].dependencies, blueprintData[assetURInh].quantities, msg.sender, msg.value));
        nftOwners[msg.sender].quantity[assetURInh] += 1;
    }
    /*
    function transfer(address _to, uint256 _tokenId) public {
        require(msg.sender == nftOwners[_tokenId]);
        idToOwner[_tokenId] = _to;
        emit Transfer(msg.sender, _to, _tokenId);
    }
    */
    
}
