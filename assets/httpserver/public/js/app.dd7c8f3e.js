(function(t){function e(e){for(var n,s,l=e[0],c=e[1],r=e[2],d=0,p=[];d<l.length;d++)s=l[d],Object.prototype.hasOwnProperty.call(a,s)&&a[s]&&p.push(a[s][0]),a[s]=0;for(n in c)Object.prototype.hasOwnProperty.call(c,n)&&(t[n]=c[n]);u&&u(e);while(p.length)p.shift()();return o.push.apply(o,r||[]),i()}function i(){for(var t,e=0;e<o.length;e++){for(var i=o[e],n=!0,l=1;l<i.length;l++){var c=i[l];0!==a[c]&&(n=!1)}n&&(o.splice(e--,1),t=s(s.s=i[0]))}return t}var n={},a={app:0},o=[];function s(e){if(n[e])return n[e].exports;var i=n[e]={i:e,l:!1,exports:{}};return t[e].call(i.exports,i,i.exports,s),i.l=!0,i.exports}s.m=t,s.c=n,s.d=function(t,e,i){s.o(t,e)||Object.defineProperty(t,e,{enumerable:!0,get:i})},s.r=function(t){"undefined"!==typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(t,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(t,"__esModule",{value:!0})},s.t=function(t,e){if(1&e&&(t=s(t)),8&e)return t;if(4&e&&"object"===typeof t&&t&&t.__esModule)return t;var i=Object.create(null);if(s.r(i),Object.defineProperty(i,"default",{enumerable:!0,value:t}),2&e&&"string"!=typeof t)for(var n in t)s.d(i,n,function(e){return t[e]}.bind(null,n));return i},s.n=function(t){var e=t&&t.__esModule?function(){return t["default"]}:function(){return t};return s.d(e,"a",e),e},s.o=function(t,e){return Object.prototype.hasOwnProperty.call(t,e)},s.p="/";var l=window["webpackJsonp"]=window["webpackJsonp"]||[],c=l.push.bind(l);l.push=e,l=l.slice();for(var r=0;r<l.length;r++)e(l[r]);var u=c;o.push([0,"chunk-vendors"]),i()})({0:function(t,e,i){t.exports=i("56d7")},"034f":function(t,e,i){"use strict";var n=i("85ec"),a=i.n(n);a.a},1573:function(t,e,i){"use strict";var n=i("9885"),a=i.n(n);a.a},"56d7":function(t,e,i){"use strict";i.r(e);i("a4d3"),i("e01a"),i("e260"),i("e6cf"),i("cca6"),i("a79d");var n=i("2b0e"),a=function(){var t=this,e=t.$createElement,i=t._self._c||e;return i("div",{attrs:{id:"app"}},[i("router-view")],1)},o=[],s={name:"app",components:{}},l=s,c=(i("034f"),i("2877")),r=Object(c["a"])(l,a,o,!1,null,null,null),u=r.exports,d=(i("0fae"),i("9e2f")),p=i.n(d);i("c69f");n["default"].use(p.a);i("d3b7");var f=i("bc3a"),h=i.n(f),m={},g=h.a.create(m);g.interceptors.request.use((function(t){return t}),(function(t){return Promise.reject(t)})),g.interceptors.response.use((function(t){return t}),(function(t){return Promise.reject(t)})),Plugin.install=function(t){t.axios=g,window.axios=g,Object.defineProperties(t.prototype,{axios:{get:function(){return g},post:function(){return g},delete:function(){return g},patch:function(){return g}},$axios:{get:function(){return g},post:function(){return g},delete:function(){return g},patch:function(){return g}}})},n["default"].use(Plugin);Plugin;var v=i("8c4f"),b=function(){var t=this,e=t.$createElement,i=t._self._c||e;return i("el-row",{staticStyle:{width:"100%",height:"100%"}},[i("el-col",{staticClass:"left hidden-sm-and-down",attrs:{xs:24,sm:6}},[i("div",{staticClass:"nav-title"},[i("div",{staticClass:"nav-title-head"},[i("img",{staticClass:"head-pic",attrs:{src:"/static/images/logo.png"},on:{click:t.handleTitleClick}}),i("span",{staticStyle:{"font-size":"22px","margin-left":"10px","font-weight":"bold",flex:"1","text-align":"left"}},[t._v("文档中心")]),i("el-button",{attrs:{icon:"el-icon-search",circle:""},on:{click:function(e){t.isSearch=!0}}})],1)]),i("el-menu",{staticClass:"el-menu-vertical-demo nav",attrs:{"default-active":t.activeIndex,mode:"vertical","background-color":"#F4F7F9","text-color":"#102030","active-text-color":"#3065BB"},on:{select:t.handleSelect}},t._l(t.menuList,(function(e){return i("el-menu-item",{key:e.id,staticClass:"menu-item",attrs:{index:""+e.id}},[i("router-link",{attrs:{to:{path:"/detail/"+e.book.book_code+"/"+e.id,params:{color:"red"}},tag:"span"}},[i("el-link",{attrs:{type:"primary"}},[i("a",{attrs:{href:"/detail/"+e.book.book_code+"/"+e.id}},[t._v(t._s(e.title))])])],1)],1)})),1),i("div",{staticClass:"nav-bottom"},[i("div",{staticClass:"sign-bottom"},[i("i",{staticClass:"el-icon-cloudy-and-sunny",staticStyle:{"font-size":"18px",padding:"8px"}}),t._v(" Powered by keli.tech ")])])],1),i("el-col",{staticStyle:{overflow:"auto",height:"100%"},attrs:{xs:24,sm:24,md:18}},[i("el-row",{staticStyle:{width:"100%",height:"100%"}},[i("el-col",{staticClass:"hidden-md-and-up",attrs:{xs:24,sm:24,md:18}},[i("div",{staticClass:"nav-title",staticStyle:{background:"white"}},[i("div",{staticClass:"nav-title-head"},[i("img",{staticClass:"head-pic",attrs:{src:"/static/images/logo.png"},on:{click:t.handleTitleClick}}),i("span",{staticStyle:{"font-size":"22px","margin-left":"10px","font-weight":"bold",flex:"1","text-align":"left"}},[t._v("文档中心")]),i("el-button",{attrs:{icon:"el-icon-search",circle:""},on:{click:function(e){t.isSearch=!0}}})],1)])]),i("el-col",{attrs:{span:6}}),t.is404?[i("div",{staticStyle:{position:"absolute",top:"0",left:"0",width:"100%",height:"100%","background-size":"100% 100%",background:"url(https://api.keli.tech/uploads/_/originals/786463a1-5b80-5a20-b88c-3fa81e72003b.jpg) no-repeat center"}},[i("div",{staticStyle:{"padding-top":"60px"}},[i("span",{staticStyle:{"font-size":"40px",color:"#B4A77B"}},[t._v("404 NOT FOUND")])])])]:i("el-col",{attrs:{xs:24,sm:24,md:18}},[i("div",{staticStyle:{"text-align":"left",margin:"0 50px","line-height":"28px"}},[i("h1",[t._v(t._s(t.article.title))]),i("div",{domProps:{innerHTML:t._s(t.article.content)}}),t.article.id?i("div",[i("el-divider"),i("span",{staticStyle:{color:"#666","font-size":"12px","padding-bottom":"20px"}},[t._v("更新时间: "+t._s(t.article.modified_on))])],1):t._e()]),i("div",{staticClass:"nav-bottom hidden-md-and-up"},[i("div",{staticClass:"sign-bottom"},[i("i",{staticClass:"el-icon-cloudy-and-sunny",staticStyle:{"font-size":"18px",padding:"8px"}}),t._v(" Powered by keli.tech ")])])]),i("el-col",{attrs:{span:6}})],2)],1),i("el-drawer",{attrs:{visible:t.isSearch,direction:"rtl","show-close":!1,size:"25%"},on:{"update:visible":function(e){t.isSearch=e}}},[i("span",{staticClass:"search-title",attrs:{slot:"title"},slot:"title"},[i("el-input",{attrs:{"prefix-icon":"el-icon-search",placeholder:"搜索",clearable:""},model:{value:t.input,callback:function(e){t.input=e},expression:"input"}}),i("el-button",{attrs:{type:"text"},on:{click:function(e){t.isSearch=!1}}},[i("i",{staticClass:"el-icon-right",staticStyle:{"font-size":"22px",padding:"5px"}})])],1),i("div",{staticStyle:{color:"#ccc"},attrs:{slot:""},slot:"default"},[t._v("- [] todo")])])],1)},x=[],y=i("d4cd"),w={name:"Home",props:{msg:String},data:function(){return{is404:!1,menuList:[],menuObj:{},isSearch:!1,input:"",book:"index",activeIndex:"-1",article:{}}},comments:{},beforeMount:function(){this.$route.params.book&&(this.book=this.$route.params.book),this.getList(this.book),this.$route.params.id&&this.getDetail(this.$route.params.id)},beforeRouteUpdate:function(t,e,i){t.params.id&&this.getDetail(t.params.id),i()},methods:{good:function(){this.$http.get()},handleTitleClick:function(){"/"===this.$route.path||(this.$router.push("/"),this.getList(this.book),this.activeIndex="1",this.getDetail(this.activeIndex))},handleSelect:function(t){t!==this.activeIndex&&(this.activeIndex=t+"",this.$router.push({name:"detail",params:{book:this.book,id:t,title:this.menuObj[t].title,keywords:this.menuObj[t].keywords,description:this.menuObj[t].description}}))},getList:function(t){var e="http://cluster2:800/_/items/blog?sort=sort&fields=id,title,keywords,description,book.book_code&filter[book.book_code][eq]="+t,i=this;i.is404=!1,this.$axios.get(e,{}).then((function(t){var e=t.data;if(!0===e.public){for(var n in i.menuList=e.data,e.data){var a=e.data[n];i.menuObj[a.id]=a}if("-1"===i.activeIndex&&i.menuList.length>0){var o=i.menuList[0].id;i.getDetail(o)}0===i.menuList.length&&(i.is404=!0)}})).catch((function(t){console.log(t,444),i.is404=!0})).then((function(){}))},getDetail:function(t){var e="http://cluster2:800/_/items/blog/"+t+"?fields=id,title,content,modified_on",i=this;i.is404=!1,i.activeIndex=t+"",this.$axios.get(e,{}).then((function(e){var n=e.data;if(!0===n.public){i.activeIndex=t+"";var a=new y;n.data.content=a.render(n.data.content),i.article=n.data,null===n.data.title&&(i.is404=!0)}})).catch((function(e){console.log(e,t,888),i.is404=!0})).then((function(){}))}}},k=w,_=(i("fb69"),Object(c["a"])(k,b,x,!1,null,"91210eba",null)),S=_.exports,C=function(){var t=this,e=t.$createElement,i=t._self._c||e;return i("el-row",{staticStyle:{width:"100%",height:"100%"}},[i("el-col",{staticClass:"hidden-xs-and-down",staticStyle:{color:"white"},attrs:{md:3,lg:4}},[t._v(".")]),i("el-col",{staticClass:"left",attrs:{xs:24,md:18,lg:16,gutter:20}},[i("div",{staticClass:"nav-title"},[i("div",{staticClass:"nav-title-head"},[i("img",{staticClass:"head-pic",attrs:{src:"/static/images/logo.png"}}),i("span",{staticStyle:{"font-size":"22px","margin-left":"10px","font-weight":"bold",flex:"1","text-align":"left"}},[t._v("文件管理")])])]),i("el-row",{staticStyle:{flex:"1","text-align":"left"}},[[i("div",{staticStyle:{"margin-top":"20px"}},[i("el-upload",{attrs:{action:"/upload",data:{path:t.currentPath},drag:"","on-success":t.getRecommendBlog,multiple:""}},[i("i",{staticClass:"el-icon-upload"}),i("div",{staticClass:"el-upload__text"},[t._v("将文件拖到此处，或"),i("em",[t._v("点击上传")])]),i("div",{staticClass:"el-upload__tip",attrs:{slot:"tip"},slot:"tip"},[t._v("上传mp3/flac等音乐文件")])]),i("el-row",{staticClass:"row-bg",attrs:{type:"flex"}},[i("el-col",{attrs:{span:12}},[i("el-button",{on:{click:t.open}},[i("i",{staticClass:"el-icon-folder-add"}),t._v(" 新建文件夹 ")])],1),i("el-col",{attrs:{span:6}}),i("el-col",{attrs:{span:3}}),i("el-col",{attrs:{span:3}},[t.lastPath.length>0?[i("el-button",{on:{click:function(e){t.currentPath=t.lastPath.pop(),t.getRecommendBlog()}}},[i("i",{staticClass:"el-icon-refresh"}),t._v(" 上一页 ")])]:t._e()],2),i("el-col",{attrs:{span:2}},[i("el-button",{on:{click:function(e){return t.getRecommendBlog()}}},[i("i",{staticClass:"el-icon-refresh"}),t._v(" 刷新 ")])],1)],1)],1),i("el-table",{ref:"multipleTable",staticStyle:{width:"100%","margin-top":"25px"},attrs:{border:"",data:t.tableData,"tooltip-effect":"dark","max-height":"550"},on:{"selection-change":t.handleSelectionChange}},[i("el-table-column",{attrs:{label:"名称","show-overflow-tooltip":""},scopedSlots:t._u([{key:"default",fn:function(e){return["fold"==e.row.type?[i("i",{staticClass:"el-icon-folder",staticStyle:{"font-size":"20px"},on:{click:function(i){t.currentPath=e.row.fullpath,t.lastPath.push(t.currentPath),t.getRecommendBlog()}}})]:"mp3"==e.row.type?[i("i",{staticClass:"iconfont",staticStyle:{"font-size":"24px"}},[t._v("")])]:"flac"==e.row.type?[i("i",{staticClass:"iconfont",staticStyle:{"font-size":"24px"}},[t._v("")])]:t._e(),i("span",{staticStyle:{"margin-left":"10px"}},[t._v(t._s(e.row.name))])]}}])}),i("el-table-column",{attrs:{label:"大小",fixed:"right",width:"120"},scopedSlots:t._u([{key:"default",fn:function(e){return[i("span",{staticStyle:{"margin-left":"10px"}},[t._v(t._s(e.row.type))])]}}])}),i("el-table-column",{attrs:{label:"操作",width:"230",fixed:"right"},scopedSlots:t._u([{key:"default",fn:function(e){return[i("el-button",{directives:[{name:"show",rawName:"v-show",value:!1,expression:"false"}],attrs:{size:"mini"},on:{click:function(i){return t.handleEdit(e.$index,e.row)}}},[i("i",{staticClass:"el-icon-files"}),t._v(" 移动 ")]),i("el-button",{attrs:{size:"mini",type:"danger"},on:{click:function(i){return t.handleDelete(e.$index,e.row)}}},[i("i",{staticClass:"el-icon-delete"}),t._v(" 删除 ")])]}}])})],1)]],2),i("div",{staticClass:"nav-bottom"},[i("div",{staticClass:"sign-bottom"},[i("i",{staticClass:"el-icon-cloudy-and-sunny",staticStyle:{"font-size":"18px",padding:"8px"}}),t._v(" Powered by keli.tech ")])])],1)],1)},P=[],$=(i("4160"),i("159b"),{name:"Home",props:{msg:String},data:function(){return{bookCluster:[],menuList:[],menuObj:{},isSearch:!1,input:"",book:"index",activeIndex:"1",article:{},recommendArticle:{},tableData:[],multipleSelection:[],currentPath:"/",lastPath:[]}},comments:{},beforeMount:function(){this.getRecommendBlog()},beforeRouteUpdate:function(t,e,i){t.params.id&&this.getDetail(t.params.id),i()},methods:{toggleSelection:function(t){var e=this;t?t.forEach((function(t){e.$refs.multipleTable.toggleRowSelection(t)})):this.$refs.multipleTable.clearSelection()},handleSelectionChange:function(t){this.multipleSelection=t},handleTitleClick:function(){"/"===this.$route.path||(this.$router.push("/"),this.getList(this.book),this.activeIndex="1",this.getDetail(this.activeIndex))},handleSelect:function(t){t!==this.activeIndex&&(this.activeIndex=t,this.$router.push({name:"detail",params:{book:this.book,id:t,title:this.menuObj[t].title,keywords:this.menuObj[t].keywords,description:this.menuObj[t].description}}))},getRecommendBlog:function(){var t="/musicList",e=this,i={params:{path:e.currentPath}};this.$axios.get(t,i).then((function(t){var i=t.data;200===i.Code&&i.Data.Total>=0&&(e.tableData=i.Data.List,console.log(e.tableData))})).catch((function(t){console.log(t,888)})).then((function(){}))},handleDelete:function(t,e){var i="/deleteMusicInfo?id="+e.id,n=this;this.$axios.delete(i,{}).then((function(t){var e=t.data;console.log(e),e.Code,n.getRecommendBlog()})).catch((function(t){console.log(t,888)})).then((function(){}))},open:function(){var t=this;this.$prompt("请输入文件夹名称","",{confirmButtonText:"确定",cancelButtonText:"取消",inputPattern:/[\u4e00-\u9fa5\w\d-_.]+/,inputErrorMessage:"输入正确的文件夹名称"}).then((function(e){var i=e.value,n="/createFold",a=t,o={path:a.currentPath,name:i};t.$axios.post(n,o).then((function(t){var e=t.data;console.log(e),200===e.Code&&a.$message({type:"success",message:"新建完成："+i}),a.getRecommendBlog()})).catch((function(t){console.log(t,888)})).then((function(){}))})).catch((function(){t.$message({type:"info",message:"取消新建"})}))}}}),O=$,j=(i("1573"),Object(c["a"])(O,C,P,!1,null,"4ae394b1",null)),z=j.exports;n["default"].use(v["a"]);var D=new v["a"]({mode:"history",routes:[{path:"/",name:"home",component:z,meta:{title:"文档中心 - 首页",content:{keywords:"文档中心",description:"文档中心"}}},{path:"/detail/:book/:id?",name:"detail",component:S,meta:{title:"文档中心 - ",content:{keywords:"文档中心",description:"文档中心"}}}]});n["default"].config.productionTip=!1;new n["default"]({router:D,beforeMount:function(){this.$router.beforeEach((function(t,e,i){if(t.meta.content){var n=document.getElementsByTagName("head"),a=document.createElement("meta"),o=t.params.keywords?t.params.keywords:t.meta.content.keywords,s=t.params.description?t.params.description:t.meta.content.description;document.querySelector('meta[name="keywords"]').setAttribute("content",o),document.querySelector('meta[name="description"]').setAttribute("content",s),a.content=t.meta.content,n[0].appendChild(a)}t.meta.title&&(document.title=t.meta.title+t.params.title),t.path,i()}))},render:function(t){return t(u)}}).$mount("#app")},8299:function(t,e,i){},"85ec":function(t,e,i){},9885:function(t,e,i){},c69f:function(t,e,i){},fb69:function(t,e,i){"use strict";var n=i("8299"),a=i.n(n);a.a}});
//# sourceMappingURL=app.dd7c8f3e.js.map