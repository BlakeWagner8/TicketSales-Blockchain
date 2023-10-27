// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract TicketSale {    
    address public manager;
    uint numTickets;
    uint ticketPrice;
    uint availableTickets;
    uint fee = 10;

struct Ticket { 
    address manager;
    bool isSold;
}

mapping(uint => Ticket) public tickets;
mapping(address => uint) public ticketOwnership;
mapping(address => address) public swapOffers;

constructor(uint num, uint price) public {
    manager=msg.sender;
    numTickets = num;
    ticketPrice = price;
    availableTickets = num;

    for(uint i = 1; i <= numTickets; i++){
        tickets[i] = Ticket({
            manager: address(0),
            isSold: false
        });
    }
}


function buyTicket(uint ticketId) public payable {
    require(msg.value == ticketPrice, "Not enough wei");
    require(!tickets[ticketId].isSold, "Ticket already sold");
    require(ticketId > 0 && ticketId < numTickets, "Invalid ticket ID");

    tickets[ticketId].manager = msg.sender;
    tickets[ticketId].isSold = true;
    availableTickets--;
    ticketOwnership[msg.sender] = ticketId;
}

function getTicketOf(address person) public view returns (uint) {
    return ticketOwnership[person];
}

function offerSwap(address partner) public {
    require(partner != msg.sender, "cannot swap with self");
    require(tickets[ticketOwnership[msg.sender]].manager == msg.sender, "Sender does not own ticket");
    require(tickets[ticketOwnership[partner]].manager == partner, "Partner does not own ticket");

    swapOffers[msg.sender] = partner;

}

function acceptSwap(address partner) public {
    require(tickets[ticketOwnership[msg.sender]].manager == msg.sender, "Sender does not own ticket");
    require(tickets[ticketOwnership[partner]].manager == partner, "Partner does not own ticket");
    require(swapOffers[partner] == msg.sender, "No swap offer");

    uint senderTicket = ticketOwnership[msg.sender];
    uint partnerTicket = ticketOwnership[partner];
    ticketOwnership[msg.sender] = partnerTicket;
    ticketOwnership[partner] = senderTicket;

    swapOffers[msg.sender] = address(0);
}

function returnTicket(uint ticketId) public {
    require(tickets[ticketId].manager == msg.sender, "Ticket not owned by sender");

    uint refundAmount = (ticketPrice - (ticketPrice * (fee / 100)));
    payable(manager).transfer(refundAmount);

    tickets[ticketId].manager = address(0);
    tickets[ticketId].isSold = false;
    availableTickets++;
    ticketOwnership[msg.sender] = 0;

}
}