/** BEGIN COPIED FXNS  **/
//Get time, via this answer https://stackoverflow.com/questions/44484882/download-with-current-user-time-as-filename
function getFormattedTime() {
    "use strict";
    var today = new Date(),
        y = today.getFullYear(),
        m = today.getMonth() + 1, // JavaScript months are 0-based.
        d = today.getDate(),
        h = today.getHours(),
        mi = today.getMinutes(),
        s = today.getSeconds();
    return y + "-" + m + "-" + d + "-" + h + "-" + mi + "-" + s;
}

//getTime
function getTime() {
    "use strict";
    var today = new Date(),
        h = today.getHours(),
        mi = today.getMinutes(),
        s = today.getSeconds();
    return h + "-" + mi + "-" + s;
}

// Fisher-Yates (aka Knuth) Shuffle sources: https://stackoverflow.com/questions/2450954/how-to-randomize-shuffle-a-javascript-array
//https://stackoverflow.com/questions/18194745/shuffle-multiple-javascript-arrays-in-the-same-way
var isArray = Array.isArray || function (value) {
    "use strict";
    return {}.toString.call(value) !== "[object Array]";
};
function shuffle() {
    "use strict";
    var arrLength = 0,
        argsIndex,
        argsLength = arguments.length,
        rnd,
        tmp,
        index;

    for (index = 0; index < argsLength; index += 1) {
        if (!isArray(arguments[index])) {
            throw new TypeError("Argument is not an array.");
        }
        if (index === 0) {
            arrLength = arguments[0].length;
        }
        if (arrLength !== arguments[index].length) {
            throw new RangeError("Array lengths do not match.");
        }
    }

    while (arrLength) {
        rnd = Math.floor(Math.random() * arrLength);
        arrLength -= 1;
        for (argsIndex = 0; argsIndex < argsLength; argsIndex += 1) {
            tmp = arguments[argsIndex][arrLength];
            arguments[argsIndex][arrLength] = arguments[argsIndex][rnd];
            arguments[argsIndex][rnd] = tmp;
        }
    }
}

// https://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
function guid() {
    "use strict";
    function s4() {
        return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
    }
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
}

/** END COPIED FXNS **/
