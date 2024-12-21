// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoursePredictionMarket {

    // Struct to store bet details
    struct Bet {
        address bettor;
        uint256 amount;
        uint256 predictedPopularity;
    }

    // Mapping for storing bets for each courseId
    mapping(uint256 => Bet[]) public courseBets;

    // Mapping for storing actual popularity for each courseId
    mapping(uint256 => uint256) public coursePopularity;

    // The owner (usually the admin) who can finalize the course popularity
    address public owner;

    // Event to log a bet placed
    event BetPlaced(address indexed bettor, uint256 courseId, uint256 predictedPopularity, uint256 amount);
    
    // Event to log the course popularity finalized
    event CourseFinalized(uint256 courseId, uint256 actualPopularity);

    // Modifier to restrict access to owner (admin)
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to place a bet on a course's popularity
    function placeBet(uint256 courseId, uint256 predictedPopularity) public payable {
        require(msg.value > 0, "Bet amount must be greater than zero");
        Bet memory newBet = Bet(msg.sender, msg.value, predictedPopularity);
        courseBets[courseId].push(newBet);

        emit BetPlaced(msg.sender, courseId, predictedPopularity, msg.value);
    }

    // Function to finalize the actual popularity of a course
    function finalizeCourse(uint256 courseId, uint256 actualPopularity) public onlyOwner {
        coursePopularity[courseId] = actualPopularity;
        emit CourseFinalized(courseId, actualPopularity);
    }

    // Function to retrieve the bets placed on a particular course
    function getBets(uint256 courseId) public view returns (Bet[] memory) {
        return courseBets[courseId];
    }

    // Function to determine the winners based on actual course popularity
    function rewardWinners(uint256 courseId) public onlyOwner {
        uint256 actualPopularity = coursePopularity[courseId];
        Bet[] memory bets = courseBets[courseId];

        for (uint i = 0; i < bets.length; i++) {
            if (bets[i].predictedPopularity == actualPopularity) {
                payable(bets[i].bettor).transfer(bets[i].amount * 2); // Rewarding the bettor with double their bet
            }
        }
    }
}
