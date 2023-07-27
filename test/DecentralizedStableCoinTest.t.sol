// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
//import {DeployDecentralicedStableCoin} from "../script/DeployDecentralicedStableCoin.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract DecentralizedStableCoinTest is Test {
    DecentralizedStableCoin public dsc;
    //  DeployDecentralicedStableCoin public deployer;

    address public USER = makeAddr("user");
    uint256 public constant STARTIN_BALANCE = 10000 ether;

    function setUp() public {
        // deployer = new DeployDecentralicedStableCoin();
        // dsc = deployer.run();
        dsc = new DecentralizedStableCoin();
        //vm.deal(msg.sender, STARTIN_BALANCE);
    }

    ///////////////////
    // Mint DSCToken///
    ///////////////////

    function testMintDSCTokenSuccess() public {
        // arrange
        vm.prank(msg.sender);
        //act
        dsc.mint(msg.sender, 1000 ether);
        //assert
        assertEq(dsc.balanceOf(msg.sender), STARTIN_BALANCE - 9000 ether);
    }

    function testFailMintDSCTokenFail() public {
        // arrange
        vm.prank(msg.sender);
        //act
        dsc.mint(msg.sender, 0 ether);
        //assert
        vm.expectRevert("DecentralizedStableCoin__MustBeMOreThanZero");
    }

    function testFailNotZeroAddress() public {
        // arrange
        vm.prank(msg.sender);
        //act
        dsc.mint(address(0), 1000 ether);
        //assert
        vm.expectRevert("DecentralizedStableCoin__NotZeroAddress");
    }

    ///////////////////
    // Burn DSCToken///
    ///////////////////

    function testBurnDSCTokenSuccess() public {
        // arrange
        vm.prank(dsc.owner());
        dsc.mint(dsc.owner(), 1000 ether);
        //act
        dsc.burn(1000 ether);
        //assert
        assertEq(dsc.balanceOf(dsc.owner()), 0);

        //  vm.startPrank(dsc.owner());
        //  dsc.mint(address(this), 1000);
        //  console.log("balance", dsc.balanceOf(address(this)));
        //  dsc.burn(500);
        //  assert(dsc.balanceOf(address(this)) == 500);
        //  vm.stopPrank();
    }

    function testBurnDSCTokenRevertExceedBalance() public {
        // Arrange
        vm.prank(dsc.owner());
        dsc.mint(dsc.owner(), 100);

        // Act/assert
        vm.expectRevert();
        dsc.burn(122 ether);
    }

    function testBrunDSCTokenRevertZeroBurn() public {
        // Arrange
        vm.prank(dsc.owner());
        dsc.mint(dsc.owner(), 100);

        // Act/assert
        vm.expectRevert();
        dsc.burn(0);
    }

    ///////////////////////
    // Transfer DSCToken///
    ///////////////////////
}
