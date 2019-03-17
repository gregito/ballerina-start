import ballerina/http;
import ballerina/time;
import ballerina/log;
import ballerina/swagger;
import ballerinax/docker;

public type TimeRequest record {
    boolean? withMilisec;
    !...;
};

public type TimeResponse record {
    string time;
    map<any>? warning;
};

const string APPLICATION_JSON = "application/json";
const string TIME_BASE_FORMAT = "HH:mm:ss";

function getFormattedTime(string format) returns string {
    return time:format(time:currentTime(), format);
}

function createTimeForPayload(http:Request request) returns string|error {
    json rj = check request.getJsonPayload();
    TimeRequest tr = check TimeRequest.convert(rj);
    var wm = tr.withMilisec;
    if (wm is boolean) {
        if (wm) {
            return getFormattedTime(string `{{ TIME_BASE_FORMAT }}.SSSZ`);
        }
    }
    return getFormattedTime(TIME_BASE_FORMAT);
}

function getTime(http:Request request) returns TimeResponse {
    TimeResponse response;
    string|error t = createTimeForPayload(request);
    response = (t is string) ? {time: t, warning: ()} : {time: getFormattedTime(TIME_BASE_FORMAT), warning: t.detail()};
    return response;
}

@docker:Config {
    registry:"gregito.project.com",
    name:"date_service",
    tag:"v1.0.0"
}
@docker:Expose{}
listener http:Listener ep0 = new(9090);
@swagger:ServiceInfo {
    title: "Date service",
    description: "Service which provides date and time related information",
    serviceVersion: "1.0.0"
}
@http:ServiceConfig {
    basePath: "/date"
}
service date on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/time",
        consumes: ["application/json"],
        produces: ["application/json"]
    }
    resource function time(http:Caller caller, http:Request request) {
        http:Response response = new;
        TimeResponse respPayload = getTime(request);
        json|error pl = json.convert(respPayload);
        error? result;
        if (pl is json) {
            response.setJsonPayload(pl, contentType = APPLICATION_JSON);
        } else {
            log:printWarn(string `error during request payload processing! >> {{ pl.reason() }}`);
            response.setJsonPayload({time: getFormattedTime(TIME_BASE_FORMAT)}, contentType = APPLICATION_JSON);
        }
        result = caller -> respond(response);
        if (result is error) {
            log:printWarn("Failed to respond to the caller");
        }
    }

}