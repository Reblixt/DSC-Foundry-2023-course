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
        vm.prank(dsc.owner());
        //act
        dsc.mint(dsc.owner(), 1000 ether);
        //assert
        assertEq(dsc.balanceOf(dsc.owner()), STARTIN_BALANCE - 9000 ether);
    }

    // function testMintDSCTokenFail() public {
    //     // arrange
    //     vm.prank(dsc.owner());
    //     //act
    //     dsc.mint(dsc.owner(), 0 ether);
    //     //assert
    //     vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__MustBeMOreThanZero.selector);
    // }

    // function testNotZeroAddress() public {
    //     // arrange
    //     vm.prank(dsc.owner());
    //     //act
    //     dsc.mint(dsc.owner(), 0 ether);
    //     //assert
    //     vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__NotZeroAddress.selector);
    // }

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

    function testTransferDSCTokenSuccess() public {
        // arrange
        vm.prank(dsc.owner());
        dsc.mint(dsc.owner(), 1000 ether);
        //act
        dsc.transfer(USER, 1000 ether);
        //assert
        assertEq(dsc.balanceOf(dsc.owner()), 0);
        assertEq(dsc.balanceOf(USER), 1000 ether);
    }

    function testTransferDSCTokenRevertExceedBalance() public {
        // Arrange
        vm.prank(dsc.owner());
        dsc.mint(dsc.owner(), 1000 ether);

        // Act/assert
        vm.expectRevert();
        dsc.transfer(USER, 1001 ether);
    }
}
