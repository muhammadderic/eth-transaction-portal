// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Transactions} from "../../contracts/Transactions.sol";

contract TransactionsInvariantTest is Test {
    Transactions public transactions;
    address public sender = address(0x123);
    address public receiver = payable(address(0x456));
    uint256 public constant INITIAL_AMOUNT = 1 ether;

    function setUp() public {
        vm.prank(sender);
        transactions = new Transactions();
    }

    // ==============================
    //  Invariant / structural tests
    // ==============================

    function test_TransactionCountMatchesArrayLength() public {
        // Add multiple transactions and verify the count always equals array length
        uint256[] memory amounts = new uint256[](5);
        amounts[0] = 1 ether;
        amounts[1] = 2 ether;
        amounts[2] = 0;
        amounts[3] = 0.5 ether;
        amounts[4] = 10 ether;

        for (uint256 i = 0; i < amounts.length; i++) {
            string memory message = string(abi.encodePacked("Invariant ", vm.toString(i)));
            string memory keyword = string(abi.encodePacked("ik", vm.toString(i)));

            vm.prank(sender);
            transactions.addToBlockchain(payable(receiver), amounts[i], message, keyword);

            uint256 count = transactions.getTransactionCount();
            Transactions.TransferStruct[] memory allTxs = transactions.getAllTransactions();
            assertEq(count, allTxs.length, "Count should always equal array length");
            assertEq(count, i + 1, "Count should increment correctly");
        }
    }
}