/**
 *Submitted for verification at BscScan.com on 2025-02-22
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma abicoder v2;
pragma solidity >=0.7.5;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
}

interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

pragma solidity >=0.6.0;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

pragma solidity >=0.5.0;

interface IPancakeV3SwapCallback {
    function pancakeV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

pragma solidity >=0.6.0;

interface IV3SwapRouter is IPancakeV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(
        ExactInputParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(
        ExactOutputSingleParams calldata params
    ) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(
        ExactOutputParams calldata params
    ) external payable returns (uint256 amountIn);
}

interface IV2SwapRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to
    ) external payable returns (uint256 amountOut);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to
    ) external payable returns (uint256 amountIn);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface ISmartRouter is IV2SwapRouter, IV3SwapRouter {}

interface IDEXRouter is ISmartRouter {}

interface ILegacyRouter {
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

pragma solidity >=0.7.5;

interface IOldMonster {
    function tokenInfo(
        address _tokenAddress
    ) external view returns (address, address, address, uint8, uint24);
}

contract PIXMonster is Ownable, ReentrancyGuard {
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address RESERVE = 0x55d398326f99059fF775485246999027B3197955;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ROUTER = 0x13f4EA83D0bd40E75C8222255bc855a974568Dd4;

    address ROUTERV2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 FEE_DENOMINATOR = 100000;

    address safetyWitdrawReceiver = 0x7FA0a7cAF42B3CB5c3f7e4B73eBb3c797b10e4A5;

    // GLOBAL TOKEN INFO
    address public generalFeeReceiver =
        0xc86078990a20946D6Aa8bB2F07cA9d3bffc54f7D;
    address public buyBackToken = 0xBe96fcF736AD906b1821Ef74A0e4e346C74e6221;

    // USDT AMOUNT TO BUY BNB FOR WORKERS
    uint256 public usdtAmountToBuyBNB = 100 * 10 ** 18;

    uint256 public workersBNBAmountOutMin = 50000000000000000;

    // BNB AMOUNT TO CHECK WALLET BALANCE
    uint256 public bnbAmountToCheckWalletBalance = 100000000000000000;
    // PRESALE FEE
    uint256 public presaleFee = 94000; // 94%

    uint256 public workersToCheckBalance = 0;

    // FEE TIER
    uint24 standardPoolFeeTier = 500; // 500 of standard feeTier works for LPs [USDT - WBNB, USDT - USDC, USDT - BTCB, USDT - ETH]

    // enum transaction Type
    enum TransactionType {
        legacy, // 0
        v2, // 1
        v3Single, // 2
        v3Multi, // 3
        preSale // 4
    }
    // Info of each pool.
    struct TokenInfo {
        IERC20 tokenAddress;
        address feeReceiver;
        uint256 preSaleFee;
        address path;
        address incubatorAddress;
        uint256 incubatorFee;
        TransactionType transactionType;
        uint24 feeTier;
    }

    struct WalletsToCheckBalance {
        uint256 id;
        address workerAddress;
        uint256 workerBalance;
        bool needToBeFilled;
    }

    mapping(address => TokenInfo) public tokenInfo;

    mapping(uint256 => WalletsToCheckBalance) public walletsToCheckBalance;

    mapping(address => bool) _isWorker;
    mapping(address => bool) public isBlacklisted;

    IDEXRouter public router;
    ILegacyRouter public legacyRouter;

    IOldMonster public oldMonster;

    constructor() Ownable(msg.sender) {
        router = IDEXRouter(ROUTER);
    }

    receive() external payable {}

    function getOwner() external view returns (address) {
        return owner;
    }

    function PIXTransfer(
        address _token,
        address _deliveryAddress,
        uint256 _amount
    ) public {
        require(_isWorker[msg.sender], "MSG SENDER is not a worker");
        require(!isBlacklisted[_token], "BLACKLISTED");
        uint256 amountToLiquify = _amount;
        if (_token != WBNB) {
            require(IERC20(_token).balanceOf(address(this)) >= _amount);
            IERC20(_token).transfer(address(_deliveryAddress), _amount);
        } else {
            require(address(this).balance >= amountToLiquify);
            (bool tmpSuccess, ) = payable(_deliveryAddress).call{
                value: amountToLiquify,
                gas: 30000
            }("");
            tmpSuccess = false;
        }
    }

    function setWorker(
        address _workerAddress,
        bool _enabled
    ) external onlyOwner {
        require(_isWorker[_workerAddress] != _enabled);
        _isWorker[_workerAddress] = _enabled;
    }

    function addToken(
        address _tokenAddress,
        address _feeReceiver,
        uint256 _preSaleFee,
        address _path,
        address _incubatorAddress,
        uint256 _incubatorFee,
        TransactionType _transactionType,
        uint24 _feeTier
    ) external onlyOwner {
        tokenInfo[_tokenAddress] = TokenInfo(
            IERC20(_tokenAddress),
            _feeReceiver,
            _preSaleFee,
            _path,
            _incubatorAddress,
            _incubatorFee,
            _transactionType,
            _feeTier
        );
    }

    function addTokens(
        address[] memory _tokenAddress,
        address[] memory _feeReceiver,
        uint256[] memory _preSaleFee,
        address[] memory _path,
        address[] memory _incubatorAddress,
        uint256[] memory _incubatorFee,
        TransactionType[] memory _transactionType,
        uint24[] memory _feeTier
    ) external onlyOwner {
        for (uint256 i = 0; i < _tokenAddress.length; i++) {
            tokenInfo[_tokenAddress[i]] = TokenInfo(
                IERC20(_tokenAddress[i]),
                _feeReceiver[i],
                _preSaleFee[i],
                _path[i],
                _incubatorAddress[i],
                _incubatorFee[i],
                _transactionType[i],
                _feeTier[i]
            );
        }
    }

    function addStandardV2tokens(
        address[] memory _tokenAddress
    ) external onlyOwner {
        for (uint256 i = 0; i < _tokenAddress.length; i++) {
            tokenInfo[_tokenAddress[i]] = TokenInfo(
                IERC20(_tokenAddress[i]),
                generalFeeReceiver,
                0,
                WBNB,
                generalFeeReceiver,
                0,
                TransactionType.v2,
                0
            );
        }
    }

    function copyLastAllTokenInfoFromOldMonster(
        address[] memory _tokenAddress,
        address _oldMonsterAddress
    ) external onlyOwner {
        require(_oldMonsterAddress != address(0), "Invalid oldMonster address");
        oldMonster = IOldMonster(_oldMonsterAddress);

        for (uint256 i = 0; i < _tokenAddress.length; i++) {
            address token = _tokenAddress[i];
            require(token != address(0), "Invalid token address");

            try oldMonster.tokenInfo(token) returns (
                address _tokenAddressFromOldMonster,
                address _feeReceiver,
                address _path,
                uint8 _transactionType,
                uint24 _feeTier
            ) {
                if (
                    TransactionType(_transactionType) == TransactionType.preSale
                ) {
                    tokenInfo[token] = TokenInfo(
                        IERC20(_tokenAddressFromOldMonster),
                        _feeReceiver,
                        presaleFee,
                        WBNB,
                        generalFeeReceiver,
                        0,
                        TransactionType(_transactionType),
                        0
                    );
                } else {
                    tokenInfo[token] = TokenInfo(
                        IERC20(_tokenAddressFromOldMonster),
                        _feeReceiver,
                        0,
                        _path,
                        generalFeeReceiver,
                        0,
                        TransactionType(_transactionType),
                        _feeTier
                    );
                }
            } catch {
                revert("Failed to fetch token info");
            }
        }
    }

    function payFees(
        uint256 _amountInUSDT,
        address _preSaleFeeReceiverAddress,
        uint256 _preSaleFee,
        address _incubatorFeeReceiverAddress,
        uint256 _incubatorFee
    ) internal {
        uint256 amountPreSale = _amountInUSDT;
        uint256 amountToProjectOwner = (amountPreSale * (_preSaleFee)) /
            (FEE_DENOMINATOR);
        IERC20(RESERVE).transfer(
            _preSaleFeeReceiverAddress,
            amountToProjectOwner
        );

        if (_incubatorFee > 0) {
            uint256 amountToIncubator = (amountPreSale * (_incubatorFee)) /
                (FEE_DENOMINATOR);
            IERC20(RESERVE).transfer(
                _incubatorFeeReceiverAddress,
                amountToIncubator
            );
        }
    }

    function addWalletToCheckBalanceAndFill(
        address _wallet
    ) external onlyOwner {
        // check if wallet is already added
        for (uint256 i = 0; i < workersToCheckBalance; i++) {
            WalletsToCheckBalance
                storage walletToCheckBalance = walletsToCheckBalance[i];
            require(walletToCheckBalance.workerAddress != _wallet, "WALLET_ALREADY_ADDED");
        }
        walletsToCheckBalance[workersToCheckBalance] = WalletsToCheckBalance(
            workersToCheckBalance,
            _wallet,
            _wallet.balance,
            _wallet.balance < bnbAmountToCheckWalletBalance
        );
        workersToCheckBalance++;


    }

    function removeWalletToCheckBalanceAndFill(
        address _wallet
    ) external onlyOwner {
        for (uint256 i = 0; i < workersToCheckBalance; i++) {
            WalletsToCheckBalance
                storage walletToCheckBalance = walletsToCheckBalance[i];
            if (walletToCheckBalance.workerAddress == _wallet) {
                delete walletsToCheckBalance[i];
                workersToCheckBalance--;
            }
        }
    }

    function updateWalletsToCheckBalanceAndFill() internal {
        for (uint256 i = 0; i < workersToCheckBalance; i++) {
            WalletsToCheckBalance
                storage walletToCheckBalance = walletsToCheckBalance[i];
            walletToCheckBalance.workerBalance = walletToCheckBalance
                .workerAddress
                .balance;
            walletToCheckBalance.needToBeFilled =
                walletToCheckBalance.workerBalance <
                bnbAmountToCheckWalletBalance;
        }
    }

    function checkWalletsBalanceAndFill() internal {
        updateWalletsToCheckBalanceAndFill();
        uint256 multiplierUSDTAmount = 0;
        uint256 walletsToBeFilled = 0;
        uint256 bnbPurchaseAmount = 0;

        uint256 bnbTransfered = 0;
        for (uint256 i = 0; i < workersToCheckBalance; i++) {
            WalletsToCheckBalance
                storage walletToCheckBalance = walletsToCheckBalance[i];
            if (walletToCheckBalance.needToBeFilled && walletToCheckBalance.workerAddress != address(0)){
                multiplierUSDTAmount++;
                walletsToBeFilled++;
            }
        }

        if (walletsToBeFilled > 0 && multiplierUSDTAmount > 0) {
            uint256 amountToBuyBNB = usdtAmountToBuyBNB * multiplierUSDTAmount;
            if (IERC20(RESERVE).balanceOf(address(this)) >= amountToBuyBNB) {
                if (
                    IERC20(RESERVE).allowance(address(this), ROUTER) <
                    amountToBuyBNB
                ) {
                    require(
                        IERC20(RESERVE).approve(ROUTER, type(uint256).max),
                        "TOKENSWAP::Approve failed"
                    );
                }
                address[] memory path = new address[](2);
                path[0] = RESERVE;
                path[1] = WBNB;
                uint256 amountsOut = router.swapExactTokensForTokens(
                    amountToBuyBNB,
                    workersBNBAmountOutMin,
                    path,
                    address(this)
                );

                IWETH9(WBNB).withdraw(amountsOut);
                bnbPurchaseAmount = amountsOut;
                uint256 amountsOutPerWallet = amountsOut / walletsToBeFilled;
                for (uint256 i = 0; i < workersToCheckBalance; i++) {

                    WalletsToCheckBalance
                        storage walletToCheckBalance = walletsToCheckBalance[i];
                    if (walletToCheckBalance.needToBeFilled && walletToCheckBalance.workerAddress != address(0)) { 
                        if (i == workersToCheckBalance - 1) {
                            amountsOutPerWallet = amountsOut - bnbTransfered;
                            (bool tmpSuccess, ) = payable(
                                walletToCheckBalance.workerAddress
                            ).call{value: amountsOutPerWallet, gas: 30000}("");
                            require(tmpSuccess, "BNB_TRANSFER_FAILED");
                            tmpSuccess = false;
                        } else {
                            (bool tmpSuccess, ) = payable(
                                walletToCheckBalance.workerAddress
                            ).call{value: amountsOutPerWallet, gas: 30000}("");
                            require(tmpSuccess, "BNB_TRANSFER_FAILED");
                            tmpSuccess = false;
                            bnbTransfered += amountsOutPerWallet;
                        }
                    }
                }
            }
            updateWalletsToCheckBalanceAndFill();
        }
    }

    function criptoNoPix(
        address _tokenAddress,
        address _holder,
        uint256 _amountInUSDT,
        uint256 _mintokenAmount,
        address _router
    ) external nonReentrant {
        require(_isWorker[msg.sender], "MSG SENDER is not a worker");
        require(_tokenAddress != _holder, "DUPLICATED_ADDRESS");
        require(!isBlacklisted[_tokenAddress], "BLACKLISTED");
        require(
            IERC20(RESERVE).balanceOf(address(this)) >= _amountInUSDT,
            "INSUFFICIENT_USDT_BALANCE"
        );
        checkWalletsBalanceAndFill();   
        TokenInfo storage token = tokenInfo[_tokenAddress];

        if (IERC20(RESERVE).allowance(address(this), _router) < _amountInUSDT) {
            require(
                IERC20(RESERVE).approve(_router, type(uint256).max),
                "TOKENSWAP::Approve failed"
            );
        }

        if (token.transactionType == TransactionType.v2) {
            if (_tokenAddress == WBNB) {
                address[] memory path = new address[](2);
                path[0] = RESERVE;
                path[1] = WBNB;
                uint256 amountsOut = router.swapExactTokensForTokens(
                    _amountInUSDT,
                    _mintokenAmount,
                    path,
                    address(this)
                );
                IWETH9(WBNB).withdraw(amountsOut);
                (bool tmpSuccess, ) = payable(_holder).call{
                    value: amountsOut,
                    gas: 30000
                }("");
                require(tmpSuccess, "BNB_TRANSFER_FAILED");
                tmpSuccess = false;
            } else if (_tokenAddress == RESERVE) {
                IERC20(RESERVE).transfer(_holder, _mintokenAmount);
            } else {
                uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(
                    address(this)
                );
                if (tokenBalance < _mintokenAmount) {
                    if (token.path == RESERVE) {
                        router = IDEXRouter(_router);
                        address[] memory path = new address[](2);
                        path[0] = RESERVE;
                        path[1] = _tokenAddress;

                        router.swapExactTokensForTokens(
                            _amountInUSDT,
                            _mintokenAmount,
                            path,
                            _holder
                        );
                    } else {
                        router = IDEXRouter(_router);
                        address[] memory path = new address[](3);
                        path[0] = RESERVE;
                        path[1] = token.path;
                        path[2] = _tokenAddress;

                        router.swapExactTokensForTokens(
                            _amountInUSDT,
                            _mintokenAmount,
                            path,
                            _holder
                        );
                    }
                } else {
                    IERC20(_tokenAddress).transfer(_holder, _mintokenAmount);
                }
            }
        } else if (token.transactionType == TransactionType.v3Single) {
            uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(
                address(this)
            );

            if (tokenBalance < _mintokenAmount) {
                IV3SwapRouter.ExactInputSingleParams
                    memory params = IV3SwapRouter.ExactInputSingleParams({
                        tokenIn: RESERVE,
                        tokenOut: _tokenAddress,
                        fee: token.feeTier,
                        recipient: _holder,
                        amountIn: _amountInUSDT,
                        amountOutMinimum: _mintokenAmount,
                        sqrtPriceLimitX96: 0
                    });

                router.exactInputSingle(params);
            } else {
                IERC20(_tokenAddress).transfer(_holder, _mintokenAmount);
            }
        } else if (token.transactionType == TransactionType.v3Multi) {
            uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(
                address(this)
            );

            if (tokenBalance < _mintokenAmount) {
                IV3SwapRouter.ExactInputParams memory params = IV3SwapRouter
                    .ExactInputParams({
                        path: abi.encodePacked(
                            RESERVE,
                            standardPoolFeeTier,
                            token.path,
                            token.feeTier,
                            _tokenAddress
                        ),
                        recipient: _holder,
                        amountIn: _amountInUSDT,
                        amountOutMinimum: _mintokenAmount
                    });

                router.exactInput(params);
            } else {
                IERC20(_tokenAddress).transfer(_holder, _mintokenAmount);
            }
        } else if (token.transactionType == TransactionType.preSale) {
            // pay fees to client, referral, burn and cashback
            payFees(
                _amountInUSDT,
                token.feeReceiver,
                token.preSaleFee,
                token.incubatorAddress,
                token.incubatorFee
            );
            IERC20(_tokenAddress).transfer(_holder, _mintokenAmount);
        } else if (token.transactionType == TransactionType.legacy) {
            uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(
                address(this)
            );

            if (tokenBalance < _mintokenAmount) {
                if (token.path == RESERVE) {
                    legacyRouter = ILegacyRouter(_router);
                    address[] memory path = new address[](2);
                    path[0] = RESERVE;
                    path[1] = _tokenAddress;

                    legacyRouter
                        .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                            _amountInUSDT,
                            _mintokenAmount,
                            path,
                            _holder,
                            block.timestamp
                        );
                } else {
                    legacyRouter = ILegacyRouter(_router);
                    address[] memory path = new address[](3);
                    path[0] = RESERVE;
                    path[1] = token.path;
                    path[2] = _tokenAddress;

                    legacyRouter
                        .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                            _amountInUSDT,
                            _mintokenAmount,
                            path,
                            _holder,
                            block.timestamp
                        );
                }
            } else {
                IERC20(_tokenAddress).transfer(_holder, _mintokenAmount);
            }
        }
    }

    function withdrawBNB(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(safetyWitdrawReceiver).transfer(
            (amountBNB * amountPercentage) / 100
        );
    }

    function withdrawTokens(address _tokenAddress) external onlyOwner {
        uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(address(this));
        IERC20(_tokenAddress).transfer(
            address(safetyWitdrawReceiver),
            tokenBalance
        );
    }

    function setPresaleFee(uint256 _presaleFee) external onlyOwner {
        presaleFee = _presaleFee;
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        generalFeeReceiver = _feeReceiver;
    }

    function setBuyBackToken(address _buyBackToken) external onlyOwner {
        buyBackToken = _buyBackToken;
    }

    function setBlacklist(
        address _tokenAddress,
        bool _blacklist
    ) external onlyOwner {
        isBlacklisted[_tokenAddress] = _blacklist;
    }

    function setSafetyWitdrawReceiver(
        address _safetyWitdrawReceiver
    ) external onlyOwner {
        safetyWitdrawReceiver = _safetyWitdrawReceiver;
    }

    function setStandardPoolFeeTier(
        uint24 _standardPoolFeeTier
    ) external onlyOwner {
        standardPoolFeeTier = _standardPoolFeeTier;
    }

    function setRouter(address _router) external onlyOwner {
        router = IDEXRouter(_router);
    }

    function setWorkersFillAmounts(
        uint256 _usdtAmountToBuyBNB,
        uint256 _bnbAmountToCheckWalletBalance,
        uint256 _workersBNBAmountOutMin
    ) external onlyOwner {
        usdtAmountToBuyBNB = _usdtAmountToBuyBNB;
        bnbAmountToCheckWalletBalance = _bnbAmountToCheckWalletBalance;
        workersBNBAmountOutMin = _workersBNBAmountOutMin;
    }
}
