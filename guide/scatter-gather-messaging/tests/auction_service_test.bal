import ballerina/test;
import ballerina/io;
import ballerina/http;
import  ballerina/runtime;

// Before Suite Function can be used to start the service
@test:BeforeSuite
function beforeSuiteFunc() {
    // Start the 'auctionService' before running the test
    var x  = test:startServices("auction_service");
    io:println(x);

    // 'auctionService' needs to communicate with bidders
    // Therefore, start these three services before running the test
    // Start the 'bidService'
    _ = test:startServices("bidders");
}

// Client endpoint
endpoint http:Client clientEP1 {
    url: "http://localhost:9090/auction"
};

// Test function
@test:Config
function testAuctionService() {
    // Initialize the empty http requests and responses
    http:Request req;

    // Request Payload
    json requestPayload = {
        "Item": "Car",
        "Condition": "good"
    };

    // Set request payload
    req.setJsonPayload(requestPayload);
    // Send a 'post' request and obtain the response
    io:println("test");
    //runtime:sleep(60000);
    http:Response response = check clientEP1->post("/setAuction", req);
    // Expected response code is 200
    test:assertEquals(response.statusCode, 200, msg = "Online auction service did not respond with 200 OK signal!");
    // Check whether the response is as expected
    // Flight details
    string expectedResult = "{\"Bidder Name\":\"Bidder 2\",\"Bid\":470000}";
    json resPayload = check response.getJsonPayload();
    test:assertEquals(resPayload.toString(), expectedResult, msg = "Response mismatch!");
}

// After Suite Function is used to stop the service
@test:AfterSuite
function afterSuiteFunc() {
    // Stop the 'auctionService' after running the test
    test:stopServices("auction_service");

    // Stop the 'bidService'
    test:stopServices("bidders");
}
