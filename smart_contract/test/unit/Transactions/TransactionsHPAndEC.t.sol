// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Transactions} from "../../../contracts/Transactions.sol";

contract TransactionsHappyPathAndEdgeCasesTest is Test {
    Transactions public transactions;
    address public sender = address(0x123);
    address public receiver = payable(address(0x456));
    uint256 public constant INITIAL_AMOUNT = 1 ether;

    function setUp() public {
        vm.prank(sender);
        transactions = new Transactions();
    }

    // =================
    //  Happy path tests
    // =================

    function test_AddTransaction() public {
        string memory message = "Hello, blockchain!";
        string memory keyword = "greeting";

        // Expect the Transfer event to be emitted
        vm.expectEmit(true, true, true, true, address(transactions));
        emit Transfer(sender, receiver, INITIAL_AMOUNT, message, block.timestamp, keyword);

        // Execute the transaction
        vm.prank(sender);
        transactions.addToBlockchain(payable(receiver), INITIAL_AMOUNT, message, keyword);

        // Verify transaction count
        uint256 count = transactions.getTransactionCount();
        assertEq(count, 1, "Transaction count should be 1");

        // Verify stored transaction data
        Transactions.TransferStruct[] memory allTxs = transactions.getAllTransactions();
        assertEq(allTxs.length, 1, "Transactions array length should be 1");

        Transactions.TransferStruct memory txData = allTxs[0];
        assertEq(txData.sender, sender, "Sender mismatch");
        assertEq(txData.receiver, receiver, "Receiver mismatch");
        assertEq(txData.amount, INITIAL_AMOUNT, "Amount mismatch");
        assertEq(txData.message, message, "Message mismatch");
        assertEq(txData.timestamp, block.timestamp, "Timestamp mismatch");
        assertEq(txData.keyword, keyword, "Keyword mismatch");
    }

    function test_GetAllTransactions_Empty() public view {
        Transactions.TransferStruct[] memory allTxs = transactions.getAllTransactions();
        assertEq(allTxs.length, 0, "Should return empty array initially");
    }

    function test_GetTransactionCount_Initial() public view {
        uint256 count = transactions.getTransactionCount();
        assertEq(count, 0, "Initial count should be 0");
    }

    function test_MultipleTransactions() public {
        uint256 numTxs = 3;

        for (uint256 i = 0; i < numTxs; i++) {
            string memory message = string(abi.encodePacked("Tx #", vm.toString(i)));
            string memory keyword = string(abi.encodePacked("key", vm.toString(i)));
            uint256 amount = (i + 1) * 0.1 ether;

            vm.prank(sender);
            transactions.addToBlockchain(payable(receiver), amount, message, keyword);
        }

        uint256 count = transactions.getTransactionCount();
        assertEq(count, numTxs, "Transaction count should match number of additions");

        Transactions.TransferStruct[] memory allTxs = transactions.getAllTransactions();
        assertEq(allTxs.length, numTxs, "Array length should match");

        // Verify each entry
        for (uint256 i = 0; i < numTxs; i++) {
            uint256 amount = (i + 1) * 0.1 ether;
            string memory expectedMessage = string(abi.encodePacked("Tx #", vm.toString(i)));
            string memory expectedKeyword = string(abi.encodePacked("key", vm.toString(i)));

            assertEq(allTxs[i].sender, sender, "Sender mismatch at index");
            assertEq(allTxs[i].receiver, receiver, "Receiver mismatch at index");
            assertEq(allTxs[i].amount, amount, "Amount mismatch at index");
            assertEq(allTxs[i].message, expectedMessage, "Message mismatch at index");
            assertEq(allTxs[i].keyword, expectedKeyword, "Keyword mismatch at index");
        }
    }

    // ============
    //  Edge cases
    // ============

    function test_AddTransaction_ZeroAmount() public {
        uint256 zeroAmount = 0;
        string memory message = "Zero amount transaction";
        string memory keyword = "zero";

        vm.prank(sender);
        transactions.addToBlockchain(payable(receiver), zeroAmount, message, keyword);

        uint256 count = transactions.getTransactionCount();
        assertEq(count, 1, "Transaction should succeed with zero amount");

        Transactions.TransferStruct[] memory allTxs = transactions.getAllTransactions();
        assertEq(allTxs[0].amount, 0, "Amount should be zero");
    }

    function test_AddTransaction_EmptyMessage() public {
        string memory emptyMessage = "";
        string memory keyword = "emptyMsg";

        vm.prank(sender);
        transactions.addToBlockchain(payable(receiver), INITIAL_AMOUNT, emptyMessage, keyword);

        uint256 count = transactions.getTransactionCount();
        assertEq(count, 1, "Transaction should succeed with empty message");

        Transactions.TransferStruct[] memory allTxs = transactions.getAllTransactions();
        assertEq(allTxs[0].message, "", "Message should be empty");
    }

    function test_AddTransaction_EmptyKeyword() public {
        string memory message = "Empty keyword test";
        string memory emptyKeyword = "";

        vm.prank(sender);
        transactions.addToBlockchain(payable(receiver), INITIAL_AMOUNT, message, emptyKeyword);

        uint256 count = transactions.getTransactionCount();
        assertEq(count, 1, "Transaction should succeed with empty keyword");

        Transactions.TransferStruct[] memory allTxs = transactions.getAllTransactions();
        assertEq(allTxs[0].keyword, "", "Keyword should be empty");
    }

    function test_AddTransaction_LongMessageAndKeyword() public {
        // Build a long string (e.g., 500 characters)
        string memory longMessage = "a";
        string memory longKeyword = "b";
        for (uint256 i = 0; i < 100; i++) {
            longMessage = string(abi.encodePacked(longMessage, "aaaaaaaaaa"));
            longKeyword = string(abi.encodePacked(longKeyword, "bbbbbbbbbb"));
        }

        vm.prank(sender);
        transactions.addToBlockchain(payable(receiver), INITIAL_AMOUNT, longMessage, longKeyword);

        uint256 count = transactions.getTransactionCount();
        assertEq(count, 1, "Transaction should succeed with long strings");

        Transactions.TransferStruct[] memory allTxs = transactions.getAllTransactions();
        assertEq(allTxs[0].message, longMessage, "Long message mismatch");
        assertEq(allTxs[0].keyword, longKeyword, "Long keyword mismatch");
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