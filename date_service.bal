import ballerina/http;
import ballerina/time;
import ballerina/io;
import ballerina/log;
import ballerina/swagger;
import ballerinax/docker;

type TimeRequest record {
    boolean? withMilisec;
    !...
};

string responseTypeJson = "application/json";
string respErr = "Failed to respond to the caller";

function getTime(http:Request request) returns string {
        string formatBase = "HH:mm:ss";
        json|error rj = request.getJsonPayload();
        string returnVal;
        if (rj is json) {
            TimeRequest|error tr = TimeRequest.convert(rj);
            if (tr is TimeRequest) {
                var wm = tr.withMilisec;
                if (wm is boolean) {
                    if (wm) {
                        return time:currentTime().format(string `{{ formatBase }}.SSSZ`);
                    }
                }   
            }
        }
        return time:currentTime().format(formatBase);
    }

function responseWithPayload(string|json payload, string contentType) returns http:Response {
    http:Response response = new;
    if (payload is string) {
        response.setTextPayload(payload, contentType = contentType);   
    } else {
        response.setTextPayload(payload.toString(), contentType = contentType);
    }
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
        path: "/time"
    }
    resource function time(http:Caller caller, http:Request request) {
        http:Response response;
        response = responseWithPayload(string `time: {{getTime(request)}}`, responseTypeJson);
        error? result = caller -> respond(response);
        if (result is error) {
            log:printWarn(respErr);
        }
    }

}