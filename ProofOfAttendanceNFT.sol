// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProofOfAttendanceNFT {
    // Variables
    string public name = "ProofOfAttendanceNFT";
    string public symbol = "POA";
    string public baseTokenURI;
    uint256 public tokenCounter;
    address public owner;

    // Mapping to store token ownership
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Mint(address indexed recipient, uint256 tokenId, string tokenURI);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor(string memory _baseURI) {
        owner = msg.sender;
        baseTokenURI = _baseURI;
        tokenCounter = 0;
    }

    // Modifier to restrict access to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    // Function to mint a new Proof of Attendance NFT
    function mint(address recipient, string memory eventURI) public onlyOwner returns (uint256) {
        uint256 tokenId = tokenCounter;
        _mint(recipient, tokenId);
        _setTokenURI(tokenId, eventURI);
        tokenCounter += 1;
        emit Mint(recipient, tokenId, eventURI);
        return tokenId;
    }

    // Internal function to mint the NFT (assign token to recipient)
    function _mint(address recipient, uint256 tokenId) internal {
        require(_owners[tokenId] == address(0), "Token ID already exists");
        _owners[tokenId] = recipient;
        _balances[recipient] += 1;
        emit Transfer(address(0), recipient, tokenId);
    }

    // Function to set the token URI for a specific token
    function _setTokenURI(uint256 tokenId, string memory eventURI) internal {
        _tokenURIs[tokenId] = string(abi.encodePacked(baseTokenURI, eventURI));
    }

    // Function to get the token URI of a specific token
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenURIs[tokenId];
    }

    // Function to transfer ownership of an NFT
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(from == msg.sender || _operatorApprovals[from][msg.sender], "Caller is not approved for transfer");
        require(_owners[tokenId] == from, "Token is not owned by the sender");
        
        _transfer(from, to, tokenId);
    }

    // Internal function to handle the transfer of tokens
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(to != address(0), "Invalid address");

        // Clear the approval for this token
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    // Function to approve a specific address to transfer a specific token
    function approve(address to, uint256 tokenId) public {
        address ownerOfToken = _owners[tokenId];
        require(to != ownerOfToken, "Approval to current owner is unnecessary");

        require(msg.sender == ownerOfToken, "Only the token owner can approve transfers");

        _approve(to, tokenId);
    }

    // Internal function to approve an address for a specific token
    function _approve(address to, uint256 tokenId) internal {
        emit Approval(_owners[tokenId], to, tokenId);
    }

    // Function to set approval for all tokens owned by the sender
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Setting approval status for oneself");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // Function to check if an address is approved to transfer a specific token
    function isApprovedForAll(address account, address operator) public view returns (bool) {
        return _operatorApprovals[account][operator];
    }

    // Function to get the balance (number of tokens) of an address
    function balanceOf(address account) public view returns (uint256) {
        require(account != address(0), "Address cannot be the zero address");
        return _balances[account];
    }

    // Function to get the owner of a specific token
    function ownerOf(uint256 tokenId) public view returns (address) {
        address ownerOfToken = _owners[tokenId];
        require(ownerOfToken != address(0), "Token does not exist");
        return ownerOfToken;
    }

    // Function to update the base URI (useful for changing metadata links)
    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseTokenURI = _baseURI;
    }

    // Function to withdraw funds from the contract (optional for resale value)
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Function to receive Ether (necessary for resale value)
    receive() external payable {}
}
