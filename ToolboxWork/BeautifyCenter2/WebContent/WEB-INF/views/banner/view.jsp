<%@page import="com.toolbox.common.AppMarketEnum"%>
<%@page import="com.toolbox.utils.JSONUtility"%>
<%@page import="com.toolbox.common.LanguageEnum"%>
<%@page import="com.toolbox.common.BannerEnum"%>
<%@page import="com.toolbox.web.entity.BannerEntity"%>
<%@page import="com.toolbox.common.SystemConfigEnum"%>
<%@page import="com.toolbox.common.AppEnum"%>
<%@page import="com.toolbox.framework.utils.ConfigUtility"%>
<%@page import="java.util.List"%>
<%@page import="com.toolbox.framework.utils.WebUtility"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String basePath = WebUtility.getBasePath(request);
String img_path = ConfigUtility.getInstance().getString("file.server.path");
List<BannerEntity> banners = (List<BannerEntity>) request.getAttribute("banners");
String bannerType = (String) request.getAttribute("bannerType");
AppEnum[] apps = AppEnum.values();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<script src="<%=basePath %>static/jquery-2.2.0.min.js"></script>
<style type="text/css">
 ul{list-style:none;}
 ul li {float: left;}
</style>
<script type="text/javascript">
function addBanner() {
	$("#addForm").show();
}
function delBanner(elementId) {
	if(confirm("确定删除？")) {
		$.get("<%=basePath%>banner/del/"+elementId, {}, function(result) {
			window.location.reload();
		});
	}
}
function searchContent() {
	var appType = $("#appType option:selected").val();
	var elementId = $("#sea_elementId").val();
	$.post("<%=basePath%>banner/search", {"appType":appType, "elementId":elementId}, function(banner) {
		if(!banner) {
			alert("没有找到");
			return;
		}
		//$.parseJSON("{" + result + "}");
		var data = eval('('+banner+')');
		var html = "<img src='<%=img_path%>"+data.previewImageUrl+"' width='330' height='292'>";
		$("#searchContent").show();
		$("#searchInfoContent").html(html);
		
	});
}
</script>
</head>
<body>
<button onclick="addBanner()">添加<%=BannerEnum.byType(bannerType).getName() %></button>
<a href="<%=basePath %>banner/<%=BannerEnum.byType(bannerType).getType() %>/view/<%=AppMarketEnum.China.getCode()%>">国内列表</a>
<a href="<%=basePath %>banner/<%=BannerEnum.byType(bannerType).getType() %>/view/<%=AppMarketEnum.GooglePlay.getCode()%>">海外列表</a>
<br />
<form action="<%=basePath%>banner/add" method="post" enctype="multipart/form-data" style="display: none;" id="addForm">
<input type="hidden" name="bannerType" value="<%=bannerType%>">
<table border="1">
	<tr>
		<td>选择封面</td>
		<td>
			<input type="file" name="cover">
		</td>
	</tr>
	<tr>
		<td>描述</td>
		<td><input type="text" name="title"></td>
	</tr>
<%if(BannerEnum.H5.getType().equals(bannerType)) {%>
	<tr>
		<td>H5链接</td>
		<td>
			<input type="text" name="h5url">
		</td>
	</tr>
<%}%>
	<tr>
		<td>打开方式</td>
		<td>
			<select name="isOpenInBrowser">
				<option value="false">webview</option>
				<option value="true">系统浏览器</option>
			</select>
		</td>
	</tr>
	<tr>
		<td>上架范围</td>
		<td>
			<input type="radio" name="market" class="market" value="<%=AppMarketEnum.China.getCode() %>" checked ><%=AppMarketEnum.China.getName() %>
			<input type="radio" name="market" class="market" value="<%=AppMarketEnum.GooglePlay.getCode() %>"><%=AppMarketEnum.GooglePlay.getName() %>
		</td>
	</tr>	
	<tr>
		<td colspan="2"><button type="submit">保  存</button></td>
	</tr>
</table>
</form>

<ul>
<%for(int i=0; i<banners.size(); i++) {
    	BannerEntity banner = banners.get(i);%>
	<li>
		<table>
				<tr>
					<td>
						<img alt="封面" src="<%=img_path%><%=banner.getPreviewImageUrl()%>" width="330" height="292">
					</td>
				</tr>
				<tr>
					<td>ID:<%=banner.getElementId() %></td>
				</tr>
				<tr>
					<td>Title: <%=banner.getTitle() %></td>
				</tr>
				<tr>
					<td>
						<a href="javascript:delBanner('<%=banner.getElementId()%>')">删除</a>
						<a href="<%=basePath%>banner/edit/<%=banner.getElementId()%>">编辑</a>
					</td>
				</tr>						
		</table>
	</li>
<%}%>
</ul>
</body>
</html>