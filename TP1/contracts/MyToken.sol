// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    mapping (address => bool) isBlocked;

    uint256 _totalSupply;
    string _name;
    string _symbol;
    address _administrator;
    uint256 _tokenPrice;

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(isBlocked[account] != true, "Account is blocked");
        require(msg.sender == _administrator, "Not admin");

        _totalSupply += amount;
    unchecked {
        // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
        balances[account] += amount;
    }
        emit Transfer(address(0), account, amount);
    }

    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }
    function balanceOf(address tokenOwner) public view returns (uint){
        return balances[tokenOwner];
    }
    function allowance(address owner, address delegate) public view returns (uint){
        return allowed[owner][delegate];
    }
    function transfer(address receiver, uint numTokens) public payable returns (bool){
        require(numTokens <= balances[msg.sender], "Not enough tokens");
        require(isBlocked[receiver] != true, "Receiver account is blocked");
        require(isBlocked[msg.sender] != true, "Your account is blocked");

        balances[msg.sender] = balances[msg.sender] - numTokens;
        balances[receiver] = balances[receiver] + numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    function approve(address delegate, uint numTokens)  public returns (bool){
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    function transferFrom(address owner, address buyer, uint numTokens) public payable returns (bool){
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        require(isBlocked[owner] != true, "Owner's account is blocked");
        require(isBlocked[buyer] != true, "Buyer's account is blocked");

        balances[owner] = balances[owner] - numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender] - numTokens;
        balances[buyer] = balances[buyer] + numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    function name() public view virtual returns (string memory) {
        return _name;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


}

contract MyTokenAdvanced is MyToken {

    constructor(uint256 initialSupply, address admin, uint priceInWei) {
        _name = "MyToken";
        _symbol = "MT";
        _totalSupply = initialSupply;
        _administrator = admin;
        _tokenPrice = priceInWei;
        balances[address(this)] = _totalSupply;
    }


    function transferOwnership(address newAdmin) public returns (bool){
        require(msg.sender == _administrator);
        _administrator = newAdmin;
        return true;
    }

    function blockAccount(address account) public returns (bool) {
        require(msg.sender == _administrator);
        isBlocked[account] = true;
        return true;
    }

    function unblockAccount(address account) public returns (bool) {
        require(msg.sender == _administrator);
        isBlocked[account] = false;
        return true;
    }

    function setTokenPrice(uint256 price) public returns (uint) {
        require(msg.sender == _administrator);
        _tokenPrice = price;
        return price;
    }

    function sell(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Not enough tokens");
        require(isBlocked[msg.sender] != true, "Your account is blocked");
        uint value = amount * (_tokenPrice * 1 ether);
        balances[address(this)] += amount;
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(value);
    }

    function buy(uint256 amount) public payable {
        require(balances[address(this)] >= amount, "Not enough tokens");
        require(isBlocked[msg.sender] != true, "Your account is blocked");
        require(msg.value >= amount * (_tokenPrice * 1 ether), "Incorrect amount of ether sent");
        balances[address(this)] -= amount;
        balances[msg.sender] += amount;
    }
}