// SPDX-License-Identifier:MIT

pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../../script/DeployOurToken.s.sol";
import {OurToken} from "../../src/OurToken.sol";

contract OurTokenTest is Test {
    // Define the events you want to test
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    OurToken public ourToken;
    DeployOurToken public deployer;
    address public user = makeAddr("user");
    address public user2 = makeAddr("user2");
    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 1000000 ether; // Adjust based on your deployment script

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(address(deployer));
        ourToken.transfer(user, STARTING_BALANCE);
    }

    // Basic Token Information Tests
    function testTokenNameAndSymbol() public {
        assertEq(ourToken.name(), "OurToken");
        assertEq(ourToken.symbol(), "TT");
    }

    function testTokenDecimals() public {
        assertEq(ourToken.decimals(), 18);
    }

    // Initial Supply Tests
    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY);
    }

    function testDeployerBalance() public {
        assertEq(
            ourToken.balanceOf(address(deployer)),
            INITIAL_SUPPLY - STARTING_BALANCE
        );
    }

    function testUserStartingBalance() public {
        assertEq(ourToken.balanceOf(user), STARTING_BALANCE);
    }

    // Transfer Tests
    function testUserCanTransferTokens() public {
        uint256 transferAmount = 10 ether;

        vm.prank(user);
        bool success = ourToken.transfer(user2, transferAmount);

        assertTrue(success);
        assertEq(ourToken.balanceOf(user), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(user2), transferAmount);
    }

    function testTransferEmitsEvent() public {
        uint256 transferAmount = 10 ether;

        vm.prank(user);
        vm.expectEmit(true, true, false, true);
        emit Transfer(user, user2, transferAmount);
        ourToken.transfer(user2, transferAmount);
    }

    function testFailTransferInsufficientBalance() public {
        uint256 transferAmount = STARTING_BALANCE + 1;

        vm.prank(user);
        ourToken.transfer(user2, transferAmount);
    }

    function testTransferToZeroAddress() public {
        uint256 transferAmount = 10 ether;

        vm.prank(user);
        vm.expectRevert();
        ourToken.transfer(address(0), transferAmount);
    }

    // Approval and TransferFrom Tests
    function testApprove() public {
        uint256 approvalAmount = 10 ether;

        vm.prank(user);
        bool success = ourToken.approve(user2, approvalAmount);

        assertTrue(success);
        assertEq(ourToken.allowance(user, user2), approvalAmount);
    }

    function testApproveEmitsEvent() public {
        uint256 approvalAmount = 10 ether;

        vm.prank(user);
        vm.expectEmit(true, true, false, true);
        emit Approval(user, user2, approvalAmount);
        ourToken.approve(user2, approvalAmount);
    }

    function testTransferFrom() public {
        uint256 approvalAmount = 10 ether;
        uint256 transferAmount = 5 ether;

        // User approves User2 to spend tokens
        vm.prank(user);
        ourToken.approve(user2, approvalAmount);

        // User2 transfers tokens from User to themselves
        vm.prank(user2);
        bool success = ourToken.transferFrom(user, user2, transferAmount);

        assertTrue(success);
        assertEq(ourToken.balanceOf(user), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(user2), transferAmount);
        assertEq(
            ourToken.allowance(user, user2),
            approvalAmount - transferAmount
        );
    }

    function testFailTransferFromInsufficientAllowance() public {
        uint256 approvalAmount = 5 ether;
        uint256 transferAmount = 10 ether;

        vm.prank(user);
        ourToken.approve(user2, approvalAmount);

        vm.prank(user2);
        ourToken.transferFrom(user, user2, transferAmount);
    }

    function testFailTransferFromInsufficientBalance() public {
        uint256 approvalAmount = STARTING_BALANCE + 10 ether;
        uint256 transferAmount = STARTING_BALANCE + 1;

        vm.prank(user);
        ourToken.approve(user2, approvalAmount);

        vm.prank(user2);
        ourToken.transferFrom(user, user2, transferAmount);
    }

    // Burning Tests (since ERC20Burnable is implemented)
    function testBurnTokens() public {
        uint256 burnAmount = 10 ether;
        uint256 initialSupply = ourToken.totalSupply();

        vm.prank(user);
        ourToken.burn(burnAmount);

        assertEq(ourToken.totalSupply(), initialSupply - burnAmount);
        assertEq(ourToken.balanceOf(user), STARTING_BALANCE - burnAmount);
    }

    function testBurnFromTokens() public {
        uint256 burnAmount = 10 ether;
        uint256 initialSupply = ourToken.totalSupply();

        vm.prank(user);
        ourToken.approve(user2, burnAmount);

        vm.prank(user2);
        ourToken.burnFrom(user, burnAmount);

        assertEq(ourToken.totalSupply(), initialSupply - burnAmount);
        assertEq(ourToken.balanceOf(user), STARTING_BALANCE - burnAmount);
        assertEq(ourToken.allowance(user, user2), 0);
    }

    // Minting Tests (since mint function is implemented)
    function testMintTokens() public {
        uint256 mintAmount = 100 ether;
        uint256 initialSupply = ourToken.totalSupply();

        vm.prank(address(deployer)); // Deployer is the owner
        ourToken.mint(user, mintAmount);

        assertEq(ourToken.totalSupply(), initialSupply + mintAmount);
        assertEq(ourToken.balanceOf(user), STARTING_BALANCE + mintAmount);
    }

    function testFailMintFromNonOwner() public {
        uint256 mintAmount = 100 ether;

        vm.prank(user); // User is not the owner
        ourToken.mint(user2, mintAmount);
    }

    // Ownership Tests (since Ownable is implemented)
    function testOwnerIsMsgSender() public {
        assertEq(ourToken.owner(), address(deployer));
    }

    function testTransferOwnership() public {
        vm.prank(address(deployer));
        ourToken.transferOwnership(user);

        assertEq(ourToken.owner(), user);
    }

    function testFailTransferOwnershipFromNonOwner() public {
        vm.prank(user);
        ourToken.transferOwnership(user2);
    }

    // Fuzz tests
    function testFuzz_Transfer(uint256 amount) public {
        // Bound the amount to avoid overflow
        vm.assume(amount <= STARTING_BALANCE);

        vm.prank(user);
        bool success = ourToken.transfer(user2, amount);

        assertTrue(success);
        assertEq(ourToken.balanceOf(user), STARTING_BALANCE - amount);
        assertEq(ourToken.balanceOf(user2), amount);
    }

    function testFuzz_Approve(uint256 amount) public {
        vm.prank(user);
        bool success = ourToken.approve(user2, amount);

        assertTrue(success);
        assertEq(ourToken.allowance(user, user2), amount);
    }

    function testFuzz_TransferFrom(
        uint256 approvalAmount,
        uint256 transferAmount
    ) public {
        vm.assume(approvalAmount <= type(uint256).max);
        vm.assume(transferAmount <= approvalAmount);
        vm.assume(transferAmount <= STARTING_BALANCE);

        vm.prank(user);
        ourToken.approve(user2, approvalAmount);

        vm.prank(user2);
        bool success = ourToken.transferFrom(user, user2, transferAmount);

        assertTrue(success);
        assertEq(ourToken.balanceOf(user), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(user2), transferAmount);
        assertEq(
            ourToken.allowance(user, user2),
            approvalAmount - transferAmount
        );
    }

    function testFuzz_Burn(uint256 burnAmount) public {
        vm.assume(burnAmount <= STARTING_BALANCE);

        uint256 initialSupply = ourToken.totalSupply();

        vm.prank(user);
        ourToken.burn(burnAmount);

        assertEq(ourToken.totalSupply(), initialSupply - burnAmount);
        assertEq(ourToken.balanceOf(user), STARTING_BALANCE - burnAmount);
    }
}
