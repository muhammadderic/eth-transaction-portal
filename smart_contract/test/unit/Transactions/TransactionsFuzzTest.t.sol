// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Transactions} from "../../../contracts/Transactions.sol";

contract TransactionsFuzzTest is Test {
    Transactions public transactions;
    address public sender = address(0x123);
    address public receiver = payable(address(0x456));

    function setUp() public {
        vm.prank(sender);
        transactions = new Transactions();
    }

    // ============
    //  Fuzz tests
    // ============

    function testFuzz_AddTransaction_AnyAmount(uint256 amount) public {
        // Bound amount to avoid overflow or extreme gas costs (practical range)
        amount = bound(amount, 0, 1000 ether);

        string memory message = "Fuzz test";
        string memory keyword = "fuzz";

        vm.prank(sender);
        transactions.addToBlockchain(payable(receiver), amount, message, keyword);

        uint256 count = transactions.getTransactionCount();
        assertEq(count, 1, "Transaction count should be 1");

        Transactions.TransferStruct[] memory allTxs = transactions.getAllTransactions();
        assertEq(allTxs[0].amount, amount, "Fuzzed amount mismatch");
        assertEq(allTxs[0].sender, sender, "Sender mismatch in fuzz");
        assertEq(allTxs[0].receiver, receiver, "Receiver mismatch in fuzz");
        assertEq(allTxs[0].message, message, "Message mismatch in fuzz");
        assertEq(allTxs[0].keyword, keyword, "Keyword mismatch in fuzz");
    }

    function testFuzz_AddTransaction_AnyMessageAndKeyword(string calldata message, string calldata keyword) public {
        // Restrict length to avoid extremely long strings (gas / DoS)
        vm.assume(bytes(message).length <= 256);
        vm.assume(bytes(keyword).length <= 64);

        uint256 amount = 0.5 ether;

        vm.prank(sender);
        transactions.addToBlockchain(payable(receiver), amount, message, keyword);

        uint256 count = transactions.getTransactionCount();
        assertEq(count, 1, "Transaction count should be 1");

        Transactions.TransferStruct[] memory allTxs = transactions.getAllTransactions();
        assertEq(allTxs[0].message, message, "Fuzzed message mismatch");
        assertEq(allTxs[0].keyword, keyword, "Fuzzed keyword mismatch");
    }

    function testFuzz_AddTransaction_AnySender(address randomSender, uint256 amount) public {
        // Ensure the sender is not the zero address (though contract allows it)
        vm.assume(randomSender != address(0));
        amount = bound(amount, 0, 100 ether);

        string memory message = "Fuzz sender";
        string memory keyword = "senderFuzz";

        vm.prank(randomSender);
        transactions.addToBlockchain(payable(receiver), amount, message, keyword);

        uint256 count = transactions.getTransactionCount();
        assertEq(count, 1, "Transaction count should be 1");

        Transactions.TransferStruct[] memory allTxs = transactions.getAllTransactions();
        assertEq(allTxs[0].sender, randomSender, "Fuzzed sender mismatch");
        assertEq(allTxs[0].amount, amount, "Fuzzed amount mismatch");
    }

    function testFuzz_MultipleTransactions(uint8 numTxs, uint256 amountBase) public {
        // Bound numTxs to a reasonable range (1-20)
        uint256 n = bound(numTxs, 1, 20);
        amountBase = bound(amountBase, 0, 100 ether);

        for (uint256 i = 0; i < n; i++) {
            uint256 amount = amountBase + (i * 0.1 ether);
            string memory message = string(abi.encodePacked("Fuzz ", vm.toString(i)));
            string memory keyword = string(abi.encodePacked("fk", vm.toString(i)));

            vm.prank(sender);
            transactions.addToBlockchain(payable(receiver), amount, message, keyword);
        }

        uint256 count = transactions.getTransactionCount();
        assertEq(count, n, "Fuzzed count mismatch");

        Transactions.TransferStruct[] memory allTxs = transactions.getAllTransactions();
        assertEq(allTxs.length, n, "Fuzzed array length mismatch");

        // Spot-check the last transaction
        uint256 lastIndex = n - 1;
        uint256 expectedAmount = amountBase + (lastIndex * 0.1 ether);
        string memory expectedMessage = string(abi.encodePacked("Fuzz ", vm.toString(lastIndex)));
        string memory expectedKeyword = string(abi.encodePacked("fk", vm.toString(lastIndex)));

        assertEq(allTxs[lastIndex].amount, expectedAmount, "Last amount mismatch in fuzz");
        assertEq(allTxs[lastIndex].message, expectedMessage, "Last message mismatch in fuzz");
        assertEq(allTxs[lastIndex].keyword, expectedKeyword, "Last keyword mismatch in fuzz");
    }
}