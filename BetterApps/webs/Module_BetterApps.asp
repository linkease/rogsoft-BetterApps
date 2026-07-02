<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta HTTP-EQUIV="Pragma" CONTENT="no-cache" />
    <meta HTTP-EQUIV="Expires" CONTENT="-1" />
    <link rel="shortcut icon" href="images/favicon.png" />
    <link rel="icon" href="images/favicon.png" />
    <title>软件中心 - BetterApps</title>
    <link rel="stylesheet" type="text/css" href="index_style.css" />
    <link rel="stylesheet" type="text/css" href="form_style.css" />
    <link rel="stylesheet" type="text/css" href="usp_style.css" />
    <link rel="stylesheet" type="text/css" href="ParentalControl.css">
    <link rel="stylesheet" type="text/css" href="css/element.css">
    <link rel="stylesheet" type="text/css" href="res/softcenter.css">
    <script language="JavaScript" type="text/javascript" src="/state.js"></script>
    <script language="JavaScript" type="text/javascript" src="/popup.js"></script>
    <script language="JavaScript" type="text/javascript" src="/validator.js"></script>
    <script language="JavaScript" type="text/javascript" src="/help.js"></script>
    <script language="JavaScript" type="text/javascript" src="/general.js"></script>
    <script>
        window.BetterAppsDefine = window.define;
        window.define = undefined;
    </script>
    <script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
    <script>
        window.define = window.BetterAppsDefine;
        window.BetterAppsDefine = undefined;
    </script>
    <script language="JavaScript" type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
    <script language="JavaScript" type="text/javascript" src="/res/softcenter.js"></script>
    <style>
        .betterapps_btn { border: 1px solid #222; background: linear-gradient(to bottom, #003333 0%, #000000 100%); font-size: 10pt; color: #fff; padding: 5px 8px; border-radius: 5px; min-width: 120px; display: inline-block; text-align: center; }
        .betterapps_btn:hover { border: 1px solid #222; background: linear-gradient(to bottom, #27c9c9 0%, #279fd9 100%); color: #fff; }
        .betterapps_msg { margin: 10px; }
    </style>
    <script>
        var r_lan_ipaddr = "<% nvram_get(lan_ipaddr); %>";
        var params_check = ["BetterApps_enable"];
        var dbus = {};

        function init() {
            show_menu(menu_hook);
            get_dbus_data();
            get_status();
        }

        function get_dbus_data() {
            $.ajax({
                type: "GET",
                url: "/_api/BetterApps",
                dataType: "json",
                async: false,
                success: function (data) {
                    dbus = data && data.result && data.result[0] ? data.result[0] : {};
                    conf_to_obj();
                    generate_link();
                }
            });
        }

        function conf_to_obj() {
            for (var i = 0; i < params_check.length; i++) {
                if (dbus[params_check[i]]) {
                    E(params_check[i]).checked = dbus[params_check[i]] == "1";
                }
            }
        }

        function save() {
            for (var i = 0; i < params_check.length; i++) {
                dbus[params_check[i]] = E(params_check[i]).checked ? "1" : "0";
            }
            showLoading();
            push_data(dbus, 1);
        }

        function push_data(obj, arg) {
            var id = parseInt(Math.random() * 100000000);
            var postData = { "id": id, "method": "BetterApps_config.sh", "params": [arg], "fields": obj };
            $.ajax({
                url: "/_api/",
                cache: false,
                type: "POST",
                dataType: "json",
                data: JSON.stringify(postData),
                success: function (response) {
                    if (response.result == id) {
                        refreshpage();
                    }
                }
            });
        }

        function generate_link() {
            var app = E("BetterApps_website");
            app.href = "/apps/";
            app.style.display = dbus["BetterApps_enable"] == "1" ? "" : "none";
        }

        function get_status() {
            $.ajax({
                type: "GET",
                cache: false,
                url: "/apps/api/v1/health",
                dataType: "json",
                success: function (response) {
                    var health = response && response.data ? response.data.status : "";
                    E("status").innerHTML = health == "healthy" ? "进程运行正常，服务健康" : "【警告】：进程运行异常，服务未就绪";
                    setTimeout("get_status();", 10000);
                },
                error: function () {
                    E("status").innerHTML = "【警告】：运行中，但是无法工作，请更新最新固件。";
                    setTimeout("get_status();", 5000);
                }
            });
        }

        function menu_hook(title, tab) {
            tabtitle[tabtitle.length - 1] = new Array("", "BetterApps");
            tablink[tablink.length - 1] = new Array("", "Module_BetterApps.asp");
        }
    </script>
</head>
<body onload="init();">
    <div id="TopBanner"></div>
    <div id="Loading" class="popup_bg"></div>
    <iframe name="hidden_frame" id="hidden_frame" style="display:none;"></iframe>
    <form method="post" name="form" action="applydb.cgi?p=BetterApps" target="hidden_frame">
        <input type="hidden" name="current_page" value="Module_BetterApps.asp" />
        <input type="hidden" name="next_page" value="Module_BetterApps.asp" />
        <input type="hidden" name="group_id" value="" />
        <input type="hidden" name="modified" value="0" />
        <input type="hidden" name="action_mode" value="" />
        <input type="hidden" name="action_script" value="" />
        <input type="hidden" name="action_wait" value="5" />
        <input type="hidden" name="first_time" value="" />
        <input type="hidden" name="SystemCmd" onkeydown="onSubmitCtrl(this, ' Refresh ')" />
        <input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>" />
        <table class="content" align="center" cellpadding="0" cellspacing="0">
            <tr>
                <td width="17">&nbsp;</td>
                <td valign="top" width="202"><div id="mainMenu"></div><div id="subMenu"></div></td>
                <td valign="top">
                    <div id="tabMenu" class="submenuBlock"></div>
                    <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
                        <tr><td align="left" valign="top">
                            <table width="760px" border="0" cellpadding="5" cellspacing="0" class="FormTitle" id="FormTitle">
                                <tr><td bgcolor="#4D595D" colspan="3" valign="top">
                                    <div>&nbsp;</div>
                                    <div class="formfonttitle">BetterApps</div>
                                    <div style="float:right; width:15px; height:25px;margin-top:-20px">
                                        <img id="return_btn" onclick="reload_Soft_Center();" align="right"
                                            style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;"
                                            title="返回软件中心" src="/images/backprev.png"
                                            onMouseOver="this.src='/images/backprevclick.png'"
                                            onMouseOut="this.src='/images/backprev.png'"></img>
                                    </div>
                                    <div style="margin:10px 0 10px 5px;" class="splitLine"></div>
                                    <div class="betterapps_msg">BetterApps for Asus/ROG router</div>
                                    <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable">
                                        <thead><tr><td colspan="2">BetterApps 设置</td></tr></thead>
                                        <tr>
                                            <th>启用 BetterApps</th>
                                            <td>
                                                <div class="switch_field">
                                                    <label for="BetterApps_enable">
                                                        <input id="BetterApps_enable" class="switch" type="checkbox" style="display:none;">
                                                        <div class="switch_container"><div class="switch_bar"></div><div class="switch_circle transition_style"><div></div></div></div>
                                                    </label>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr><th>运行状态</th><td><span id="status">检查中...</span></td></tr>
                                        <tr><th>访问入口</th><td><a id="BetterApps_website" class="betterapps_btn" target="_blank">打开 BetterApps</a></td></tr>
                                    </table>
                                    <div class="apply_gen"><input class="button_gen" onclick="save();" type="button" value="保存" /></div>
                                </td></tr>
                            </table>
                        </td></tr>
                    </table>
                </td>
                <td width="10" align="center" valign="top"></td>
            </tr>
        </table>
    </form>
    <div id="footer"></div>
    <div id="OverlayMask" class="popup_bg">
        <div align="center">
            <iframe src="" frameborder="0" scrolling="no" id="popupframe" width="400" height="400"
                allowtransparency="true" style="margin-top:150px;"></iframe>
        </div>
    </div>
</body>
</html>
