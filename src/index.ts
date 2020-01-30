import * as AWS from "aws-sdk";

// tslint:disable-next-line:no-var-requires
const axios = require("axios").default;

exports.handler = async (event) => {
    const {API_HOST, API_KEY_REF, DATA, ENDPOINT, HEADERS, HTTP_VERB, IS_SSL, REGION} = event;
    const API_URL = `http${IS_SSL ? "s" : ""}://${API_HOST || "localhost"}`;
    const url = API_URL + ENDPOINT;

    try {
        const apiKey = await getParam(API_KEY_REF, REGION);
        HEADERS.headers.Authorization = apiKey;

        let response;
        if (HTTP_VERB === "DELETE") {
            response = await axios.delete(url, HEADERS);
        } else if (HTTP_VERB === "POST") {
            response = await axios.post(url, DATA || {}, HEADERS);
        } else {
            response = await axios.get(url, HEADERS);
        }
        // tslint:disable-next-line:no-console
        console.log("RESPONSE: ", response);
        return {
            body: JSON.stringify(response.data),
            statusCode: response.status,
        };
    } catch (e) {
        // tslint:disable-next-line
        console.log(e);
        return e;
    }
};

const getParam = async (secretName, region) => {
    AWS.config.update({
        region: region || "eu-west-2",
    });

    const parameterStore = new AWS.SSM();

    const params = {
        Name: secretName,
        WithDecryption: true,
    };

    try {
        const result = await parameterStore.getParameter(params).promise();
        return result.Parameter.Value;
    } catch (e) {
        // tslint:disable-next-line
        console.log(e);
        return e;
    }
};
