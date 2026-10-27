/**
 * viewer를 띄우기 위한 js 및 css 파일 로드
 */
function readyViewer() {
    // jQuery 스크립트 로드
    var jqueryScript = document.createElement("script");
    jqueryScript.src = "../diagnostics/viewer/js/jquery-3.5.1.min.js";
    jqueryScript.type = "text/javascript";
    document.head.appendChild(jqueryScript);

    // crownix-viewer 스크립트 로드
    var viewerScript = document.createElement("script");
    viewerScript.src = "../diagnostics/viewer/js/crownix-viewer.storage.min.js";
    viewerScript.type = "text/javascript";
    document.head.appendChild(viewerScript);

    // CSS 파일 로드
    var viewerCss = document.createElement("link");
    viewerCss.rel = "stylesheet";
    viewerCss.href = "../diagnostics/viewer/css/crownix-viewer.min.css";
    document.head.appendChild(viewerCss);
}

/**
 * report 생성을 위한 viewer 코드
 * mrdPath : 절대경로로만 변경 가능
 */
function makeViewer() {
        var href = window.location.href;
        var serverHome = href.substr(0, href.lastIndexOf('/', href.indexOf('manager')));
        var serviceUrl = serverHome + '/service';

        var viewer = new m2soft.crownix.Viewer(serviceUrl, 'crownix-viewer');
        viewer.hideToolbarItem(['first', 'last', 'print', 'search', 'inquery']);

        var mrdPath = "diagnostics.mrd";
        var mrdParam = "";

        viewer.bind("report-finished", function (event) {
            window.parent.onReportFinished();
        });
}

function getMakeViewerStr()
{
    var functionStr = makeViewer.toString();
    var body = functionStr.match(/{([\s\S]*)}/)[1].trim();
    return body;
}


window.externalFunctions = {
    readyViewer,
    getMakeViewerStr
};
