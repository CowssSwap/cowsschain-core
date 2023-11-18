pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract test is Test {
    struct Order {
        address user;
        bytes data;
    }

    function setUp() public {
        Order memory order = Order({user: address(0), data: abi.encode(0)});

        keccak256(abi.encode(order));
    }
}
