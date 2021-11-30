//SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;
    
    mapping(address => uint256) public addressToAmountFunded;
    
    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;
    
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }
    
    function fund() public payable {
        uint256 minimumUSD = 112 * 10 ** 13;
        require(getConversionRate(msg.value) >= getConversionRate(minimumUSD), "The amount should not be less than 50 dollars");
        
        addressToAmountFunded[msg.sender] += msg.value; 
        funders.push(msg.sender);
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner of this contract, THIEF!!!");
        _;
    }
    
    function withdraw() onlyOwner public payable {
        msg.sender.transfer(address(this).balance);
        
        for(uint256 funderIndex; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        
        funders = new address[](0);
    }
    
    function getVersion() public view returns(uint256) {
        return priceFeed.version();
    }
    
    function getPrice() public view returns(uint256){
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
        //428190000000
    }
    
    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount)/1000000000000000000;
        return ethAmountInUsd;
        //40724695744
    }

    function getEntranceFee() public view returns (uint256) {
        //minimumUSD
        uint256 minimumUSD = 112 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }
}