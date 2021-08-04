contract AddrResolver {
    function addr(bytes32 nodeID) public returns (address) {
        return address(this);
    }
}