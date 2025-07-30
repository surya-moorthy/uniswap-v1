// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Factory.sol";
import "../src/Exchange.sol";
import "../src/ERC20.sol";

contract FactoryTest is Test {
    Factory public factory;
    MyToken public token;

    address tokenOwner = makeAddr("owner");

    function setUp() public {
        token = new MyToken(tokenOwner);
        factory = new Factory();
    }

    function testCreateNewExchange() public {
        address tokenExchangeAddress = factory.createNewExchange(address(token));
        assertEq(factory.getExchange(address(token)), tokenExchangeAddress, "Exchange address does not match");
        assertTrue(tokenExchangeAddress != address(0), "Exchange address should not be 0x0");
    }

    function test_RevertWhen_CreatingExchangeForExistingToken() public {
    factory.createNewExchange(address(token)); // first time works
    vm.expectRevert("Exchange already exists"); // expect revert next time
    factory.createNewExchange(address(token)); // this should revert
}

}