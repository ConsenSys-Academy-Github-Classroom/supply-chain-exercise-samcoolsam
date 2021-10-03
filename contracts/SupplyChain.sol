// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {


  uint count = 0;

  mapping(uint => Item) items;

  enum State{ForSale, Sold, Shipped, Received}

  struct Item{
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  }


  /* 
   * Events
   */

  
  event LogForSale(uint sku);
 
  event LogSold(uint sku);
  
  event LogShipped(uint sku);

  event LogReceived(uint sku);



  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract

  // <modifier: isOwner

  modifier verifyCaller (address _address) { 
    // require (msg.sender == _address); 
    _;
  }

  modifier paidEnough(uint _price) { 
    require(msg.value >= _price, "Not enough money paid"); 
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
     uint _price = items[_sku].price;
     uint amountToRefund = msg.value - _price;
     items[_sku].buyer.transfer(amountToRefund);
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?

  // modifier forSale
  modifier forSale(uint _sku){
    require(items[_sku].state == State.ForSale, "Item not for sale");
    _;
  }
  modifier sold(uint _sku) {
    require(items[_sku].state == State.Sold, "Item isn't sold");
    _;
  }

  modifier sellerCheck(uint _sku){
    require(items[_sku].seller == msg.sender, "You don't own the item");
    _;
  }
   modifier shipped(uint _sku) {
     require(items[_sku].state == State.Shipped, "Item isn't shipped yet");
    _;
   }

   modifier buyerCheck(uint _sku){
    require(items[_sku].buyer == msg.sender, "You don't buy the item");
    _;
  }
  // modifier received(uint _sku) 

  constructor() public {
    // 1. Set the owner to the transaction sender
    // 2. Initialize the sku count to 0. Question, is this necessary?
  }

  function addItem(string memory _name, uint _price) public returns (bool) {

    
    items[count] = Item({
      name: _name,
      sku: count,
      price: _price,
      state: State.ForSale,
      seller: msg.sender,
      buyer: 0x0000000000000000000000000000000000000000
    });

    emit LogForSale(count);
    count++;

    
    return true;
  }


  function buyItem(uint sku) public payable forSale(sku) paidEnough(items[sku].price) checkValue(sku){
    items[sku].buyer = msg.sender;
    items[sku].state = State.Sold;
    uint _price = items[sku].price;
    items[sku].seller.transfer(_price);
  
  emit LogSold(sku);

  }

  // 1. Add modifiers to check:
  //    - the item is sold already 
  //    - the person calling this function is the seller. 
  // 2. Change the state of the item to shipped. 
  // 3. call the event associated with this function!
  function shipItem(uint sku) public sold(sku) sellerCheck(sku){

    items[sku].state = State.Shipped;
    emit LogShipped(sku);

  }

  // 1. Add modifiers to check 
  //    - the item is shipped already 
  //    - the person calling this function is the buyer. 
  // 2. Change the state of the item to received. 
  // 3. Call the event associated with this function!
  function receiveItem(uint sku) public shipped(sku) buyerCheck(sku){
    items[sku].state = State.Received;
    emit LogReceived(sku);

  }

  // Uncomment the following code block. it is needed to run tests
   function fetchItem(uint _sku) public view
     returns (string memory name, uint sku, uint price, uint state, address seller, address buyer)
   { 
     name = items[_sku].name;
     sku = items[_sku].sku; 
     price = items[_sku].price; 
     state = uint(items[_sku].state); 
     seller = items[_sku].seller; 
     buyer = items[_sku].buyer; 
    return (name, sku, price, state, seller, buyer); 
   } 

  function owner() public {}
  function skuCount() public {}
}
