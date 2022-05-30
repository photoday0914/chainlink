// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol"; //SafeMath is generally not needed starting with Solidity 0.8, since the compiler now has built in overflow checking.

contract FundMe {
    // using SafeMath for uint256;
    mapping(address => uint256) public addressToAmount;
    address owner;
    address[] public funders;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        //5$        
        uint256 minimumUSD = 5 * 10 ** 18;
        require (getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!"); //revert transaction if not satisfied
        addressToAmount[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function getBTCtoEther() public view returns (uint256) {
        AggregatorV3Interface priceFeed =  AggregatorV3Interface(0xF7904a295A029a3aBDFFB6F12755974a958C7C25);
        (, int price,,,) = priceFeed.latestRoundData();
        return uint256(price * 10 ** 10);
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / (10 * 18);
        return ethAmountInUSD;
    }

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    function withdraw() payable onlyOwner public {
        
        payable(msg.sender).transfer(address(this).balance);
        //since all the deposited amount has been withdrawn
        for (uint256 funderIndex = 0; funderIndex < funders.length ; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmount[funder] = 0;
        }
        //funders array will be initialized to 0
        funders = new address[](0);
    }

}