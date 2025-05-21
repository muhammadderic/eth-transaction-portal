// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Transactions} from "../../../contracts/Transactions.sol";

contract TransactionsEventEmissionTest is Test {
    Transactions public transactions;
    address public sender = address(0x123);
    address public receiver = payable(address(0x456));
    uint256 public constant INITIAL_AMOUNT = 1 ether;

    function setUp() public {
        vm.prank(sender);
        transactions = new Transactions();
    }

    // ======================
    //  Event emission tests
    // ======================

    function test_EventEmission_ExactValues() public {
        string memory message = "Event check";
        string memory keyword = "eventKey";
        uint256 amount = 5 ether;

        // Set up the exact event we expect
        vm.expectEmit(true, true, true, true, address(transactions));
        emit Transfer(sender, receiver, amount, message, block.timestamp, keyword);

        vm.prank(sender);
        transactions.addToBlockchain(payable(receiver), amount, message, keyword);
    }

    function test_EventEmission_TimestampMatchesBlock() public {
        string memory message = "Timestamp test";
        string memory keyword = "ts";
        uint256 amount = 2 ether;

        // Advance time to a specific timestamp for deterministic testing
        uint256 expectedTimestamp = 1_700_000_000;
        vm.warp(expectedTimestamp);

        vm.expectEmit(true, true, true, true, address(transactions));
        emit Transfer(sender, receiver, amount, message, expectedTimestamp, keyword);

        vm.prank(sender);
        transactions.addToBlockchain(payable(receiver), amount, message, keyword);
    }

    // Helper event for vm.expectEmit
    event Transfer(
        address from,
        address receiver,
        uint amount,
        string message,
        uint256 timestamp,
        string keyword
    );
}