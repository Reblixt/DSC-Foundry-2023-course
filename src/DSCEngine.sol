// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.19;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title DSCEngine
 * @author Reblixt
 * The system is designed to be as minimal possilbe, and have the tokens maintain a 1 token == 1$ peg.
 * This Stablecoin has this properties:
 * - Exogenous collateral
 * - Dollar pegged
 * - Algoritmically stable
 *
 * it is similar to DAI if DAI had no governance, no fees, and was only backed by WETH and WBTC.
 *
 * Our DSC system should always be "overcollateralized". At no point, should the value of all collateral <= the % backed value of all the DSC.
 *
 * @notice this contract is the core of the DSC system. it handles all the logic for miniting and redeeming DSC tokens. as well depositiong & withdrawing collateral.
 * @notice This contract is VERY loosley based on the MakerDAO DSS (DAI) system.
 */

contract DSCEnigne is ReentrancyGuard {
    /////////////
    //Errors/////
    /////////////
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__TokenNotAllowed();

    //////////////////
    //State Varibles//
    //////////////////
    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amnount)) private s_collateralDeposited;

    DecentralizedStableCoin private immutable i_dsc;

    //////////////////
    //Events        //
    //////////////////
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    /////////////
    //Modifiers//
    /////////////

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed();
        }
        _;
    }

    /////////////
    //Functions//
    /////////////
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        // USD Price Feeds
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }
        // For Example ETH/USD, BTC/USD, LINK/USD
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    //////////////////////
    //External functions//
    //////////////////////

    function depositCollateralAndMintDsc() external {}

    /**
     * @notice follows CEI pattern
     * @param tokenCollateralAddress the address of the collateral token to deposit
     * @ param amountCollateral
     *
     */

    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
