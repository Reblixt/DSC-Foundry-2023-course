// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine engine;
    HelperConfig config;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address weth;

    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 100 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth,,) = config.activeNetworkConfig();

        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);
    }

    //////////////////
    // Modifiers /////
    //////////////////

    modifier depositCollateral() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        engine.depositCollateral(weth, AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;
    }
    //////////////////////////
    // Constructor Tests /////
    //////////////////////////

    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function testRevertsIfTokenLengthDoesentMatchPriceFeeds() public {
        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch.selector);
        new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
        //  address[] memory tokens = new address[](1);
        //  address[] memory priceFeeds = new address[](2);
        //  vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength.selector);
        //  new DSCEngine(tokens, priceFeeds, address(dsc));
    }

    //////////////////////////
    // Price Tests ///////////
    //////////////////////////

    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        // 15e18 * 2000/ETH = 30,000e18
        uint256 expectedUsd = 30000e18;
        uint256 actualUsd = engine.getUsdValue(weth, ethAmount);
        assertEq(expectedUsd, actualUsd);
        console.log("Actual USD: %s", actualUsd);
    }

    function testGetTokenAmountFromUsd() public {
        uint256 usdAmount = 100 ether;
        // $2,000 / ETH,$100 = 0,05 ETH
        uint256 expectedWeth = 0.05 ether;
        uint256 actualWeth = engine.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(expectedWeth, actualWeth);
    }

    ///////////////////////////
    // DepositCollateralTest //
    ///////////////////////////

    function testRevertsIfCollateralZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);

        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        engine.depositCollateral(weth, 0);
        vm.stopPrank();
    }

    function testRevertsWithUnapprovedCollateral() public {
        ERC20Mock ranToken = new ERC20Mock("RAN", "RAN", USER, AMOUNT_COLLATERAL);
        vm.startPrank(USER);
        vm.expectRevert(DSCEngine.DSCEngine__TokenNotAllowed.selector);
        engine.depositCollateral(address(ranToken), AMOUNT_COLLATERAL);
        vm.stopPrank();
    }

    function testCanDepositCollateralAndGetAccountInfo() public depositCollateral {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);
        uint256 expectedTotalDscMinted = 0;
        uint256 expectedDepositAmount = engine.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(expectedTotalDscMinted, totalDscMinted);
        assertEq(expectedDepositAmount, AMOUNT_COLLATERAL);
    }

    // denna test failar just nu p.g.a exeeded amount balance
    //  function testCanDepositCollateralAndGetAccountInfoWithMultipleDeposits() public depositCollateral {
    //      uint256 secondDeposit = 5 ether;
    //      ERC20Mock(weth).approve(address(engine), secondDeposit);
    //      engine.depositCollateral(weth, secondDeposit);
    //
    //      (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);
    //      uint256 expectedTotalDscMinted = 0;
    //      uint256 expectedDepositAmount = engine.getTokenAmountFromUsd(weth, collateralValueInUsd);
    //      assertEq(expectedTotalDscMinted, totalDscMinted);
    //      assertEq(expectedDepositAmount, AMOUNT_COLLATERAL + secondDeposit);
    //  }

    ///////////////////
    // MintDsc test ///
    ///////////////////

    function testRevertsIfMintAmountZero() public depositCollateral {
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        engine.mintDsc(0);
    }

    // Denna test får en error men Revert meddelandet är rätt
    function testRevertsIfMintAmountExceedsCollateral() public depositCollateral {
        uint256 mintAmount = 100 ether;
        vm.expectRevert(DSCEngine.DSCEngine__BreaksHealthFactor.selector);
        engine.mintDsc(mintAmount);
    }

    // Går inte att mint DSC då HealthFactor är under 1. Detta test failar just nu p.g.a health factor break. Tror detta är buggen Patric pratar om.
    function testMintSuccess() public depositCollateral {
        uint256 mintAmount = 5 ether;
        engine.mintDsc(mintAmount);
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);
        uint256 expectedTotalDscMinted = mintAmount;
        uint256 expectedDepositAmount = engine.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(expectedTotalDscMinted, totalDscMinted);
        assertEq(expectedDepositAmount, AMOUNT_COLLATERAL);
    }

    ///////////////////
    // BurnDsc Test ///
    ///////////////////

    /////////////////////
    // Liquidate Test ///
    /////////////////////

    ///////////////////////////
    // RedeemCollateralTest ///
    ///////////////////////////

    ///////////////////////////
    // getHealthFactor Test ///
    ///////////////////////////
}
