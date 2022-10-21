// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Token {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (uint256);
}

contract MultiSend {
    // to save the owner of the contract in construction
    address private owner;

    //token want to tranfer
    Token mkToken;

    // to save the amount of ethers in the smart-contract
    uint256 total_value;

    // event for EVM logging
    // event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if the caller is owner
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    //Set contract deployer as owner
    constructor(Token _tokenAddress) {
        require(
            address(_tokenAddress) != address(0),
            "Token Address cannot be address 0"
        );
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        mkToken = _tokenAddress;
        // emit OwnerSet(address(0), owner);
    }

    // the owner of the smart-contract can chage its owner to whoever
    // he/she wants
    function changeOwner(address newOwner) public isOwner {
        // emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    // @dev Return owner address
    function getOwner() external view returns (address) {
        return owner;
    }

    // charge enable the owner to store ether in the smart-contract
    function addTokenToPool(uint256 amount) external isOwner {
        // adding the message value to the smart contract

        mkToken.transferFrom(msg.sender, address(this), amount);
        total_value += amount;
    }

    function getTotalValue() external view returns (uint256) {
        return total_value;
    }

    // sum adds the different elements of the array and return its sum
    function sum(uint256[] memory amounts) public pure returns (uint256) {
        // the value of message should be exact of total amounts
        uint256 totalAmnt = 0;

        for (uint i = 0; i < amounts.length; i = unsafe_inc(i)) {
            totalAmnt += amounts[i];
        }

        return totalAmnt;
    }

    // withdraw perform the transfering of ethers
    function withdraw(address receiverAddr, uint256 receiverAmnt)
        private
        isOwner
    {
        mkToken.transfer(receiverAddr, receiverAmnt);
    }

    // withdrawlMulti enable to multiple withdraws to different accounts
    // at one call, and decrease the network fee
    function withdrawlMulti(address[] memory addrs, uint256[] memory amnts)
        external
        isOwner
    {
        uint _total_value = total_value;

        // the addresses and amounts should be same in length
        require(
            addrs.length == amnts.length,
            "The length of two array should be the same"
        );

        // the value of the message in addition to sotred value should be more than total amounts
        uint totalAmnt = sum(amnts);

        require(
            total_value >= totalAmnt,
            "The value is not sufficient or exceed"
        );
        //call unsafe_inc() để save gas
        for (uint i = 0; i < addrs.length; i = unsafe_inc(i)) {
            //nếu dùng total_value thì nó sẽ tốn nhiều gas hơn cho mỗi lần gọi đến vì là biến global,
            //tạo _total_value để gọi r update lần cuối vào total_value sẽ mất ít gas hơn
            _total_value -= amnts[i];

            // send the specified amount to the recipient
            withdraw(addrs[i], amnts[i]);
        }

        total_value = _total_value;
    }

    //use unsafe math to save gas
    function unsafe_inc(uint x) private pure returns (uint) {
        unchecked {
            return x + 1;
        }
    }
}

// pragma solidity ^0.8.0;

// interface Token {
//     function transfer(address recipient, uint256 amount)
//         external
//         returns (bool);

//     function balanceOf(address account) external view returns (uint256);

//     function transferFrom(
//         address sender,
//         address recipient,
//         uint256 amount
//     ) external returns (uint256);
// }

// contract MultiSend {
//     // to save the owner of the contract in construction
//     address private owner;

//     //token want to tranfer
//     Token mkToken;

//     // to save the amount of ethers in the smart-contract
//     uint256 total_value;

//     // event for EVM logging
//     event OwnerSet(address indexed oldOwner, address indexed newOwner);

//     // modifier to check if the caller is owner
//     modifier isOwner() {
//         require(msg.sender == owner, "Caller is not owner");
//         _;
//     }

//     //Set contract deployer as owner
//     constructor(Token _tokenAddress) {
//         require(
//             address(_tokenAddress) != address(0),
//             "Token Address cannot be address 0"
//         );
//         owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
//         mkToken = _tokenAddress;
//         emit OwnerSet(address(0), owner);
//     }

//     // the owner of the smart-contract can chage its owner to whoever
//     // he/she wants
//     function changeOwner(address newOwner) public isOwner {
//         emit OwnerSet(owner, newOwner);
//         owner = newOwner;
//     }

//     // @dev Return owner address
//     function getOwner() external view returns (address) {
//         return owner;
//     }

//     // charge enable the owner to store ether in the smart-contract
//     function addTokenToPool(uint256 amount) external isOwner {
//         // adding the message value to the smart contract

//         mkToken.transferFrom(msg.sender, address(this), amount);
//         total_value += amount;
//     }

//     function getTotalValue() external view returns (uint256) {
//         return total_value;
//     }

//     // sum adds the different elements of the array and return its sum
//     function sum(uint256[] memory amounts) public pure returns (uint256) {
//         // the value of message should be exact of total amounts
//         uint256 totalAmnt = 0;

//         for (uint i = 0; i < amounts.length; i++) {
//             totalAmnt += amounts[i];
//         }

//         return totalAmnt;
//     }

//     // withdraw perform the transfering of ethers
//     function withdraw(address receiverAddr, uint256 receiverAmnt)
//         private
//         isOwner
//     {
//         mkToken.transfer(receiverAddr, receiverAmnt);
//     }

//     // withdrawlMulti enable to multiple withdraws to different accounts
//     // at one call, and decrease the network fee
//     function withdrawlMulti(address[] memory addrs, uint256[] memory amnts)
//         external
//         isOwner
//     {
//         // the addresses and amounts should be same in length
//         require(
//             addrs.length == amnts.length,
//             "The length of two array should be the same"
//         );

//         // the value of the message in addition to sotred value should be more than total amounts
//         uint totalAmnt = sum(amnts);

//         require(
//             total_value >= totalAmnt,
//             "The value is not sufficient or exceed"
//         );

//         for (uint i = 0; i < addrs.length; i++) {
//             // first subtract the transferring amount from the total_value
//             // of the smart-contract then send it to the receiver
//             total_value -= amnts[i];

//             // send the specified amount to the recipient
//             withdraw(addrs[i], amnts[i]);
//         }
//     }
// }
