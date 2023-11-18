pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract test is Test {
    struct Order {
        address user;
        bytes data;
    }
}
