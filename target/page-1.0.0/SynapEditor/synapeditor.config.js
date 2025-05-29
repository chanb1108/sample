/**
 * 사이냅 에디터 기본 설정 객체 입니다.
 * key, value 형태로 설정하며, 사용하지 않는 설정 제거시 기본설정으로 동작합니다.
 * 'editor.license' 설정은 필수 설정이며, 미 설정시 에디터가 동작하지 않습니다.
 * 설정 객체 사용방법: 스크립트 추가, 에디터 초기화 config를 설정합니다.
 * ex)
        <!DOCTYPE html>
        <html lang="ko">
            <script src='synapeditor.config.js'></script>
            <script>
                window.onload = function() {
                    new SynapEditor('synapEditor', synapEditorConfig);
                }
            </script>
            <body>
                <div id="synapEditor"></div>
            </body>
        </html>

 * 참고 URL : https://synapeditor.com/docs/pages/viewpage.action?pageId=8421764
 */

var synapEditorConfig = {
    /**
     * 라이센스 파일의 경로 또는 라이센스 객체를 설정합니다.
     * ex) '/resource/license.json'
     * ex)  {
                'company': 'SynapSoft',
                'key': [
                    'licenseKey'
                ]
            }
     */
    'editor.license': 'SynapEditor/license.json',

    /**
     * 에디터 타입을 설정합니다.
     * ex) classic, inline, document, preview
     */
    'editor.type': null,

    /**
     * 에디터 첫 로딩후 안쪽으로 포커스 지정 여부를 설정합니다.
     */
    'editor.initFocus': true,

    /**
     * 에디터의 너비를 설정합니다.
     * ex) '100%', '600px'
     */
    'editor.size.width': '100%',

    /**
     * 에디터의 높이를 설정합니다.
     * ex) '100%', '600px'
     */
    'editor.size.height': '100%',

    /**
     * 컨텐츠의 높이에 따라 에디터 높이가 변경됩니다.
     * true로 설정시 아래설정들은 무시됩니다.
     * - 'editor.size.height' (에디터 높이설정)
     * - 'editor.mode.iframe' (iframe모드)
     */
    'editor.size.height.fit': false,

    /**
     * 에디터의 최소 높이를 설정합니다.
     * px단위로만 설정이 가능합니다.
     * 'editor.size.height.fit'값을 true로 설정시 동작합니다.
     * ex) 300
     */
    'editor.size.height.fit.min': null,

    /**
     * 에디터 너비 고정 여부를 설정합니다.
     * 너비에 px단위의 유효한 값이 설정되었을 경우에만 적용이 됩니다.
     */
    'editor.contents.fixedWidth': false,

    /**
     * 에디터 편집영역(se-contents)의 크기(px)를 설정합니다.
     * 'editor.type' 값이 'document'인 경우 적용됩니다.
     * 기본값은 MS-Word A4 기준입니다.
     */
    'editor.document.size': {
        'width': 793,
        'height': 1122,
        'padding': { 'top': 96, 'right': 96, 'bottom': 96, 'left': 96 }
    },

    /**
     * 에디터의 높이 조절가능 여부를 설정합니다.
     */
    'editor.resizable': false,

    /**
     * 언어팩이 존재하지 않을 때 기본 에디터 표시언어를 설정합니다.
     * ex) ko, en, ja, zh
     */
    'editor.lang.default': 'ko',

    /**
     * 에디터 표시언어를 직접 설정합니다.
     * null로 설정시 browser 언어로 설정되며, browser 언어 미설정시 editor.lang.default 언어로 설정됩니다.
     * ex) ko, en, ja, zh
     */
    'editor.lang': 'ko',

    /**
     * 웹페이지가 언로드되기 전, '페이지를 나가시겠습니까' 확인 메세지 표시 여부를 설정합니다.
     */
    'editor.unloadMessage': false,

    /**
     * 웹페이지가 언로드될 때 에디터 제거 여부를 설정합니다.
     */
    'editor.destroy.on.unload': true,

    /**
     * 에디터 헤더 영역을 외부 스크롤에 고정할지 여부를 설정합니다.
     */
    'editor.mode.sticky': false,

    /**
     * 에디터의 편집영역을 iframe으로 설정하기 위한 옵션 입니다.
     *  - enable      : iframe mode 설정 여부
     *  - style.urls  : iframe 내부에 추가할 스타일 url ( 'contentsEditStyle.css': iframe mode설정시 반드시 추가되야 합니다. )
     *  - script.urls : iframe 내부에 추가할 스크립트 url ( 'SEPolyfill.min.js': iframe mode설정시 반드시 추가되야 합니다. )
     * ex)
     * 'editor.mode.iframe': {
     *      'enable': true,
     *      'style.urls': ['../dist/iframeMode/contentsEditStyle.css', ... ],
     *      'script.urls': ['../dist/iframeMode/SEPolyfill.min.js']
     * }
     */
    'editor.mode.iframe': {
        'enable': false,
        'style.urls': [],
        'script.urls': []
    },

    /**
     * 에디터 가로 스크롤 사용 여부를 설정합니다.
     */
    'editor.horizontalScroll': true,

    /**
     * 에디터 툴바 버튼(드롭다운)의 크기를 설정합니다.
     * 최소값은 22 입니다. (단위 px)
     */
    'editor.ui.button.size': null,

    /**
     * 에디터 툴바 버튼(드롭다운)의 아이콘 크기를 설정합니다.
     * 최소값은 16 입니다. (단위 px)
     */
    'editor.ui.button.icon.size': null,

    /**
     * 에디터 테마를 설정합니다.
     * ex) 'dark-gray', ....
     */
    'editor.ui.theme': null,

    /**
     * 에디터 모바일 편집시 사용할 4가지 색상을 설정합니다.
     * 색상은 rgb("rgb(255, 0, 0)"), hex("#FF0000"), preset("red")형태로 설정이 가능합니다.
     */
    'editor.colorSet.mobile': ['#FF0000', '#FFFF00', '#008000', '#0000FF'],

    /**
     * 에디터 PC 편집시 사용할 7가지 색상을 설정합니다.
     * 색상은 rgb("rgb(255, 0, 0)"), hex("#FF0000"), preset("red")형태로 설정이 가능합니다.
     */
    'editor.colorSet.desktop': ['#FF0000', '#FFA500', '#FFFF00', '#008000', '#0000FF', '#4B0082', '#800080'],

    /**
     * 툴바를 설정합니다.
     * ex)  'new', 'open', 'template', 'layout', 'autoSave', 'print', 'pageBreak', 'contentsProperties', 'undo', 'redo',
            'copy', 'cut', 'paste', 'copyRunStyle', 'pasteRunStyle', 'ruler', 'guide', 'source',
            'preview', 'fullScreen', 'accessibility', 'personalDataProtection', 'find', 'conversion',
            'help', 'about', 'bulletList', 'numberedList', 'multiLevelList', 'alignLeft', 'alignCenter',
            'alignRight', 'alignJustify', 'decreaseIndent', 'increaseIndent', 'paragraphProperties',
            'link', 'unlink', 'bookmark', 'image', 'background', 'video', 'file', 'table', 'div',
            'drawAbsolutePositionDiv', 'horizontalLine', 'quote', 'specialCharacter', 'emoji',
            'paragraphStyleWithText', 'fontFamilyWithText', 'fontSizeWithText', 'lineHeightWithText',
            'bold', 'italic', 'underline', 'strike', 'growFont', 'shrinkFont', 'fontColor',
            'fontBackgroundColor', 'superScript', 'subScript', 'customRunStyle', 'removeRunStyle', 'customParagraphStyle'
     * '|' : 가로 나눔 선
     * '-' : 세로 나눔 선
     * 툴바 설정 참고 : https://synapeditor.com/docs/pages/viewpage.action?pageId=8421767
     */
    'editor.toolbar': [
        'new', 'open', 'template', 'layout', '|',
        'contentsProperties', '|',
        'undo', 'redo', '|',
        'copy', 'cut', 'paste', '|',
        'link', 'unlink', 'bookmark', '|',
        'image', 'background', 'video', 'file', '|',
        'table', 'div', 'horizontalLine', 'quote', '|',
        'specialCharacter', 'emoji', '-',
        'paragraphStyleWithText', '|',
        'fontFamilyWithText', '|',
        'fontSizeWithText', '|',
        'bold', 'italic', 'underline', 'strike', '|',
        'growFont', 'shrinkFont', '|',
        'fontColor', 'fontBackgroundColor', '|',
        'bulletList', 'numberedList', 'multiLevelList', '|',
        'align', '|',
        'lineHeight', '|',
        'decreaseIndent', 'increaseIndent'
    ],

    /**
     * 모바일용 툴바를 설정합니다.
     */
    'editor.mobile.toolbar': {
        'main': [
            'open', 'undo', 'redo', 'copy', 'paste', 'directInsertImage', 'directInsertTable', 'simpleLink', 'unlink',
            'fullScreen', 'bulletList', 'numberedList', 'multiLevelList', 'align', 'increaseIndent', 'decreaseIndent',
            'lineHeight', 'quote', 'horizontalLine'
        ],
        'text': [
            'paragraphStyle', 'fontSize',
            'bold', 'italic', 'underline', 'strike',
            'simpleFontColor', 'simpleFontBackgroundColor'
        ],
        'table': [
            'insertRowBefore', 'insertRowAfter', 'insertColBefore', 'insertColAfter',
            'deleteRow', 'deleteCol', 'mergeCell', 'simpleFill',
            'simpleBorderColor', 'lineThickness', 'lineStyle', 'contentsAlign', 'verticalAlign', 'deleteTable'
        ],
        'div': [
            'simpleDrawingObjectFill', 'simpleDrawingObjectBorderColor', 'drawingObjectLineThickness', 'drawingObjectLineStyle', 'deleteDiv'
        ],
        'image': [
            'rotateDrawingObjectLeft', 'rotateDrawingObjectRight', 'deleteImage'
        ],
        'video': [
            'deleteVideo'
        ]
    },

    /**
     * balloon 별로 들어갈 컴포넌트들을 재정의합니다.
     * [사용방법]
     * {
     *     벌룬 이름: [ui component들의 이름, ...]
     * }
     * [사용가능한 벌룬 이름들]
     * 'text', 'image', 'video', 'drawingObject', 'tableCell', 'hyperlink'
     * [예제]
     * 'editor.balloon': {
     *     text: ["bold", "italic", "underline", "strike"]
     * }
     */
    'editor.balloon': null,

    /**
     * 모바일용 벌룬을 설정합니다.
     */
    'editor.mobile.balloon': null,

    /**
     * 표 풍선팝업을 tableCellSelection일 경우에만 보여줄지 여부를 설정합니다.
     * 값이 false일 경우 표 안쪽 캐럿 상태일 경우에도 표 풍선팝업이 노출됩니다.
     */
    'editor.table.showBalloon.onlyTableCellSelection': false,

    /**
     * 메뉴 사용 여부를 설정합니다.
     */
    'editor.menu.show': true,

    /**
     * 사용할 메뉴 목록을 설정합니다.
     */
    'editor.menu.list': ['file', 'edit', 'view', 'insert', 'format', 'paragraph', 'table', 'tools', 'help'],

    /**
     * 각 메뉴 별 아이템을 설정합니다.
     */
    'editor.menu.definition': {
        'file': [
            'new', 'open', '-',
            'template', 'layout', 'autoSave', '-',
            'print', 'pageBreak', 'contentsProperties'
        ],
        'edit': [
            'undo', 'redo', '-',
            'copy', 'paste', 'cut', '-',
            'copyRunStyle', 'pasteRunStyle', '-',
            'find'
        ],
        'view': [
            'fullScreen', '-',
            'source', 'preview', '-',
            'ruler', 'guide'
        ],
        'insert': [
            'link', 'bookmark', '-',
            'image', 'background', 'video', 'file', '-',
            'div', 'drawAbsolutePositionDiv', 'horizontalLine', 'quote', '-',
            'specialCharacter', 'emoji'
        ],
        'format': [
            'bold', 'italic', 'underline', 'strike', '-',
            'superScript', 'subScript', '-',
            'removeRunStyle'
        ],
        'paragraph': [
            'increaseIndent', 'decreaseIndent',
            '-',
            {
                'groupName': 'list',
                'subMenuItems': ['bulletList', 'numberedList', 'multiLevelList']
            },
            {
                'groupName': 'align',
                'subMenuItems': ['alignLeft', 'alignCenter', 'alignRight', 'alignJustify']
            },
            '-',
            'paragraphProperties'
        ],
        'table': [
            'table', 'deleteTable', 'tableProperties', '-',
            {
                'groupName': 'row',
                'subMenuItems': ['insertRowBefore', 'insertRowAfter', 'deleteRow']
            },
            {
                'groupName': 'column',
                'subMenuItems': ['insertColBefore', 'insertColAfter', 'deleteCol']
            },
            {
                'groupName': 'cell',
                'subMenuItems': ['mergeCell', 'splitCell', 'cellProperties']
            },
            '-',
            {
                'groupName': 'numberFormat',
                'subMenuItems': [
                    'numberFormatText', 'numberFormatNumber1', 'numberFormatNumber2', 'numberFormatPercent1', 'numberFormatPercent2',
                    'numberFormatScientific', 'numberFormatAccounting', 'numberFormatCurrency', 'numberFormatDate', 'numberFormatTime'
                ]
            }
        ],
        'tools': [
            'accessibility', 'personalDataProtection', '-',
            {
                'groupName': 'conversion',
                'subMenuItems': ['upperCase', 'lowerCase', 'titleCase', 'toggleCase']
            }
        ],
        'help': [
            'help', 'shortcut', 'about'
        ]
    },

    /**
     * 에디터에서 편집시 사용가능한 폰트패밀리를 설정합니다.
     */
    'editor.fontFamily': {
        'ko': [
            '돋움', '굴림', '바탕', '궁서', '맑은 고딕',
            'Arial', 'Comic Sans MS', 'Courier New', 'Georgia',
            'Lucida Sans Unicode', 'Tahoma', 'Times New Roman', 'Trebuchet MS', 'Verdana'
        ],
        'en': [
            'Arial', 'Comic Sans MS', 'Courier New', 'Georgia',
            'Lucida Sans Unicode', 'Tahoma', 'Times New Roman', 'Trebuchet MS', 'Verdana'
        ]
    },

    /**
     * 에디터에서 편집시 사용가능한 폰트크기를 설정합니다.
     */
    'editor.fontSize': [8, 9, 10, 11, 12, 14, 16, 18, 20, 24, 28, 32, 36, 40, 44, 48, 54, 60, 72, 80, 88, 96],

    /**
     * 에디터에서 편집시 사용할 폰트크기의 단위를 설정합니다.
     * 'pt'(기본값) or 'px'
     */
    'editor.fontSize.unit': 'pt',

    /**
     * 에디터에서 편집시 사용가능한 줄간격을 설정합니다.
     * 줄간격은 0이상만 적용할 수 있습니다.
     */
    'editor.lineHeight': [1.0, 1.2, 1.4, 1.6, 1.8, 2.0, 2.5, 3.0],

    /**
     * 에디터에서 사용할 기본 스타일을 설정합니다.
     * 예제의 Element들의 속성만 지정이 가능하며, cssText 형태로 작성
     * ex) 'Body', Paragraph', 'TextRun', 'Div', 'Image', 'Video', 'List', 'ListItem'
           'Quote', 'Table', 'TableRow', 'TableCell', 'HorizontalLine', 'Iframe',
           'Heading1', 'Heading2', Heading3', Heading4', Heading5', Heading6'
     */
    'editor.defaultStyle': {
        'Body': 'font-family: 맑은 고딕; font-size: 11pt; line-height: 1.2;'
    },

    /**
     * 사용자 정의 문단, 글꼴 서식 스타일을 설정합니다.
     * paragraph: 문단 서식 스타일
     * textRun: 글꼴 서식 스타일
     */
    'editor.customStyle': {
        'paragraph': [{
            'name': 'Dark Gray',
            'style': {
                'color': { 'r': 98, 'g': 98, 'b': 98 }
            }
        }, {
            'name': 'Light Gray',
            'style': {
                'color': { 'r': 220, 'g': 220, 'b': 220 }
            }
        }],
        'textRun': [{
            'name': 'Mint 32 Bold',
            'style': {
                'fontWeight': 700,
                'fontSize': {
                    'value': 32,
                    'unit': 'pt'
                },
                'color': { 'r': 57, 'g': 182, 'b': 184 }
            }
        }, {
            'name': 'Orange 24 Bold',
            'style': {
                'fontWeight': 700,
                'fontSize': {
                    'value': 24,
                    'unit': 'pt'
                },
                'color': { 'r': 243, 'g': 151, 'b': 0 }
            }
        }]
    },

    /**
     * 임포트 시 항상 덮어쓸지(새로 넣을지) 여부를 설정합니다.
     */
    'editor.import.alwaysOverwriting': false,

    /**
     * 임포트 시 문서의 최대 사이즈를 설정합니다.
     * 단위: B(byte)
     */
    'editor.import.maxSize': 10485760,

    /**
     * 임포트 API를 설정합니다.
     * ex) '/importAPI'
     */
    'editor.import.api': '',

    /**
     * 임포트 요청 헤더를 설정합니다.
     * ex) {
     *         'key': value
     *     }
     */
    'editor.import.headers': {},

    /**
     * 임포트 요청 시 함께 보낼 기본 파라미터를 설정합니다.
     * ex)  {
                key: value
            }
     */
    'editor.import.param': null,

    /**
     * 임포트 시 에디터 편집영역 사이즈를 유지합니다.
     */
    'editor.import.keepContentsSize': false,

    /**
     * 임포트시 사용하는 formData field의 이름을 셋팅합니다.
     */
    'editor.import.fileFieldName': null,

    /**
     * 임포트 할 문서의 확장자를 설정합니다.
     */
    'editor.import.extensions': ['docx', 'doc', 'hwp', 'hwpx', 'hml', 'html', 'htm', 'txt', 'xls', 'xlsx', 'odt'],

    /**
     * 워드 계열 문서를 임포트 할 때 영역 선택 기능의 사용 여부를 설정합니다.
     */
    'editor.import.selectArea.word': false,

    /**
     * 슬라이드 계열 문서를 임포트 할 때 영역 선택 기능의 사용 여부를 설정합니다.
     */
    'editor.import.selectArea.slide': false,

    /**
     * 셀 임포트 할 때 기본 영역을 설정합니다.
     * 원활한 편집을 위해 행:'1 ~ 100', 열: 'A ~ Z(26)' 사이를 권장합니다.
     */
    'editor.import.defaultArea.cell': { startCell: 'A1', endCell: 'Z100' },

    /**
     * 셀 임포트 시 오른쪽 셀을 넘어서 글자를 표현할지 여부를 결정합니다.
     * 바로 오른쪽 셀에 글자가 없는 경우에만 넘어서 표현됩니다.
     */
    'editor.import.useOverflow.cell': false,

    /**
     * 업로드 시 파일의 최대 사이즈를 설정합니다.
     * 단위: B(byte)
     */
    'editor.upload.maxSize': 3145728,

    /**
     * base64 이미지의 최대 사이즈를 설정합니다.
     * 단위: B(byte)
     * ex) 'editor.image.base64.maxSize': 3145728 // 3MB
     */
    'editor.image.base64.maxSize': null,

    /**
     * 이미지 업로드 시 base64를 사용할 것인지를 설정합니다.
     * true로 설정이 이미지 업로드 후 base64로 이미지가 표현됩니다.
     */
    'editor.upload.image.base64': false,

    /**
     * 이미지 업로드 API를 설정합니다.
     * ex) '/imageAPI'
     */
    'editor.upload.image.api': '',

    /**
     * 이미지 업로드 요청 헤더를 설정합니다.
     * ex) {
     *         'key': value
     *     }
     */
    'editor.upload.image.headers': {},

    /**
     * 이미지 업로드 시 함께 보낼 기본 파라미터를 설정합니다.
     * ex)  {
                key: value
            }
     */
    'editor.upload.image.param': null,

    /**
     * 이미지 업로드시 사용하는 formData field의 이름을 셋팅합니다.
     */
    'editor.upload.image.fileFieldName': null,

    /**
     * 업로드 할 이미지의 확장자를 설정합니다.
     */
    'editor.upload.image.extensions': ['jpg', 'gif', 'png', 'jpeg'],

    /**
     * 이미지 업로드전 base64형태로 미리보기를 제공합니다.
     * 암호가 걸린 이미지는 업로드 되지 않을 수 있습니다.
     */
    'editor.upload.image.preview': true,


    /**
     * 한글 복사/붙여넣기시 wmf이미지 업로드 API를 설정합니다.
     * ex) '/wmfToPngAPI'
     */
    'editor.upload.wmf.api': '',

    /**
     * wmf이미지 업로드 요청 헤더를 설정합니다.
     * ex) {
     *         'key': value
     *     }
     */
    'editor.upload.wmf.headers': {},

    /**
     * wmf이미지 업로드 시 함께 보낼 기본 파라미터를 설정합니다.
     * ex)  {
     *          'key': value
     *      }
     */
    'editor.upload.wmf.param': null,

    /**
     * wmf이미지 업로드시 사용하는 formData field의 이름을 셋팅합니다.
     */
    'editor.upload.wmf.fileFieldName': null,

    /**
     * 동영상 업로드 API를 설정합니다.
     * ex) '/videoAPI'
     */
    'editor.upload.video.api': '',

    /**
     * 동영상 업로드 요청 헤더를 설정합니다.
     * ex) {
     *         'key': value
     *     }
     */
    'editor.upload.video.headers': {},

    /**
     * 동영상 업로드 시 함께 보낼 기본 파라미터를 설정합니다.
     * ex)  {
                key: value
            }
     */
    'editor.upload.video.param': null,

    /**
    * 동영상 업로드시 사용하는 formData field의 이름을 셋팅합니다.
    */
    'editor.upload.video.fileFieldName': null,

    /**
     * 업로드 할 동영상의 확장자를 설정합니다.
     */
    'editor.upload.video.extensions': ['mp4', 'ogg', 'webm'],

    /**
     * iframe으로 업로드 할 도메인을 설정합니다.
     *  - pathParts: id 앞에 위치한 path
     *  - parameter: id 앞에 위치한 param
     * ex)  {
     *          'vimeo.com': {
     *              pathParts: {
     *                  '' : 'https://player.vimeo.com/video/{id}' // domain 뒤에 바로 id가 있는 경우
     *              },
     *          },
     *          'player.vimeo.com': {
     *              pathParts: {
     *                  'video': 'https://player.vimeo.com/video/{id}'
     *              }
     *          }, // 도메인이 'vimeo.com' -> 'player.vimeo.com'으로 변경되므로 반드시 변경된 도메인도 등록해야합니다.
     *          'tv.kakao.com': { // /v 혹은 /cliplink path 뒤에 id가 있는 경우
     *              pathParts: {
     *                  'v' : 'https://play-tv.kakao.com/embed/player/cliplink/{id}',
     *                  'cliplink' : 'https://play-tv.kakao.com/embed/player/cliplink/{id}'
     *              },
     *          }
     *      }
     *  'https://vimeo.com/956202369' -> 'https://player.vimeo.com/video/956202369',
     *  'https://tv.kakao.com/channel/1506/cliplink/451928372' -> 'https://play-tv.kakao.com/embed/player/cliplink/451928372'
     */
    'editor.upload.video.embedURLTransformers': {
        'youtube.com': {
            pathParts: {
                'shorts': 'https://www.youtube.com/embed/{id}',
                'live': 'https://www.youtube.com/embed/{id}',
            },
            parameters: {
                'v': 'https://www.youtube.com/embed/{id}'
            }
        },
        'youtu.be': {
            pathParts: {
                '': 'https://www.youtube.com/embed/{id}'
            }
        },
        'tv.naver.com': {
            pathParts: {
                'v': 'https://tv.naver.com/embed/{id}',
                'h': 'https://tv.naver.com/embed/{id}'
            }
        },
        'tv.kakao.com': {
            pathParts: {
                'livelink': 'https://play-tv.kakao.com/embed/player/livelink/{id}',
                'cliplink': 'https://play-tv.kakao.com/embed/player/cliplink/{id}',
                'v': 'https://play-tv.kakao.com/embed/player/cliplink/{id}'
            }
        },
        'play-tv.kakao.com': {
            pathParts: {
                'livelink': 'https://play-tv.kakao.com/embed/player/livelink/{id}',
                'cliplink': 'https://play-tv.kakao.com/embed/player/cliplink/{id}',
                'v': 'https://play-tv.kakao.com/embed/player/cliplink/{id}'
            },
        },
        'chzzk.naver.com': {
            pathParts: {
                'clips': 'https://chzzk.naver.com/embed/clip/{id}'
            }
        },
        'vod.sooplive.co.kr': {
            pathParts: {
                'player': 'https://vod.sooplive.co.kr/player/{id}/embed'
            }
        },
        'play.sooplive.co.kr': {
            pathParts: {
                '': 'https://play.sooplive.co.kr/{id}/embed'
            }
        },
        'vimeo.com': {
            pathParts: {
                '': 'https://player.vimeo.com/video/{id}'
            }
        },
        'player.vimeo.com': {
            pathParts: {
                'video': 'https://player.vimeo.com/video/{id}'
            }
        }
    },

    /**
     * 파일 업로드 API를 설정합니다.
     * ex) '/fileAPI'
     */
    'editor.upload.file.api': '',

    /**
     * 파일 업로드 요청 헤더를 설정합니다.
     * ex) {
     *         'key': value
     *     }
     */
    'editor.upload.file.headers': {},

    /**
     * 파일 업로드 시 함께 보낼 기본 파라미터를 설정합니다.
     * ex)  {
                key: value
            }
     */
    'editor.upload.file.param': null,

    /**
     * 파일 업로드시 사용하는 formData field의 이름을 셋팅합니다.
     */
    'editor.upload.file.fileFieldName': null,

    /**
     * 업로드 할 파일의 확장자를 설정합니다.
     */
    'editor.upload.file.extensions': [
        'bmp', 'css', 'csv', 'diff', 'doc',
        'docx', 'eof', 'gif', 'jpeg', 'jpg',
        'json', 'mp3', 'mp4', 'm4a', 'odp',
        'ods', 'odt', 'ogg', 'otf', 'patch',
        'pdf', 'png', 'ppt', 'pptx', 'rtf',
        'svg', 'swf', 'textile', 'tif', 'tiff',
        'ttf', 'txt', 'wav', 'webm', 'woff',
        'xls', 'xlsx', 'xml', 'md', 'vtt',
        'hwp', 'hml', 'html'
    ],

    /**
     * 다운로드 할 이미지의 URL 패턴을 설정합니다.
     */
    'editor.download.image.pattern': '',

    /**
     * 미리보기에 스타일 url을 추가합니다.
     * ex) ['dist/css/myStyle.css']
     */
    'editor.preview.style.urls': [],

    /**
     * 템플릿을 설정합니다.
     * ex) [
                {
                'category': 'template_category1',
                'label': '양식',
                'items': [
                    {
                    'name': '템플릿 아이템',
                    'path': '/resource/template/template1.html'
                    }
                ]
                }
            ]
     */
    'editor.template': [],

    /**
     * 템플릿 요청 헤더를 설정합니다.
     * ex) {
     *         'key': value
     *     }
     */
    'editor.template.headers': {},

    /**
     * 테이블 템플릿 스타일을 설정합니다.
     * {
     *     templateName: {                                      // templateName에 해당하는 테이블 템플릿 스타일을 정의합니다.
     *        row: {                                            // 행들의 스타일을 정의합니다.
     *          head: {                                         // 머리행의 스타일을 정의합니다.
     *            index: 0,                                     // number: 스타일을 적용할 행을 선택합니다.
     *            style: {                                      // StyleObject: 표현할 스타일을 정의합니다.
     *              color: 'rgb(255, 255, 255)',              // string: ['red'|'rgb(255, 0, 0)'|'#FF0000'] 글자색을 지정합니다.
     *              backgroundColor: 'rgb(255, 255, 255)',    // string: [red'|'rgb(255, 0, 0)'|'#FF0000'] 배경색을 지정합니다.
     *              borders: {                                  // 테두리의 스타일을 정의합니다.
     *                top: {                                    // BorderObject: border-top 정의
     *                  tpye: 'solid',                          // string: ['solid'|'dashed'|'dotted'|'double'|'none'] 테두리 스타일을 지정합니다.
     *                                                                     테두리 스타일이 'double'일 경우, 테두리 두께(width)가 3 이상일 때만 이중선으로 표현됩니다.
     *                  width: 1,                               // number: 테두리 두께를 px 단위로 지정합니다. (0~10 사이의 값만 설정 가능합니다)
     *                  color: 'rgb(255, 255, 255)'           // string: [red'|'rgb(255, 0, 0)'|'#FF0000'] 테두리 색상을 지정합니다.
     *                },
     *                bottom: ...,                              // BorderObject: 설정하지 않으면 top이 적용됩니다.
     *                left: ...,                                // BorderObject: 설정하지 않으면 top이 적용됩니다.
     *                right: ...                                // BorderObject: 설정하지 않으면 left -> top 순서로 적용됩니다.
     *              }
     *            }
     *          },
     *          highlight: {                                    // 강조행의 스타일을 정의합니다.
     *              isEven: true,                               // boolean: [true|false] 짝수행에 적용할지 여부입니다. true일 경우 짝수행에 false일 경우 홀수행에 지정됩니다.
     *              style: {...}                                // StyleObject: 강조행의 스타일을 정의합니다.
     *          }
     *        },
     *        col: {...},                                       // 열들의 스타일을 정의합니다.
     *                                                             형태는 row와 같습니다.
     *        defaultStyle: {...},                              // StyleObject: 기본 셀 스타일을 정의합니다.
     *        tableStyle: {...}                                 // StyleObject: 기본 표 스타일을 정의합니다.
     *     }
     * }
     */
    'editor.table.template.styles': {},

    /**
     * 테이블 템플릿을 설정합니다.
     */
    'editor.table.template.list': {
        popup: [
            ['Basic', 'Gray Column Header', 'Gray Row Header', 'Dual Header'],
            ['Sideless Zebra', 'Sideless GrayScale', 'GrayScale', 'Striped Black Row Header']
        ],
        dialog: [
            ['Basic', 'Dashed', 'GrayScale', 'Zebra'],
            ['Sideless', 'Sideless Zebra', 'Sideless GrayScale', 'Sideless Black'],
            ['Gray Column Header', 'Dashed Gray Column Header', 'Dual Header', 'Dashed Dual Header'],
            ['Gray Row Header', 'Dashed Gray Row Header', 'Sideless Black Row Header', 'Striped Black Row Header']
        ]
    },

    /**
     * 자동 저장 여부를 설정합니다.
     */
    'editor.autoSave': false,

    /**
     * 자동 저장 주기를 설정합니다.
     * 단위: ms
     */
    'editor.autoSave.period': 60000,

    /**
     * 자동저장 키를 설정합니다.
     */
    'editor.autoSave.key': null,

    /**
     * 최근 사용한 색 목록 키를 설정합니다.
     */
    'editor.recentColorList.key': null,

    /**
     * 툴팁위치를 저장하기위한 키를 설정합니다.
     */
    'editor.tooltip.position.key': null,

    /**
     * 단축키 툴팁을 보여줄지 여부를 설정합니다.
     */
    'editor.tooltip.showShortcut': true,

    /**
     * <iframe>태그 필터링을 설정합니다.
     */
    'editor.contentFilter.allowIframe': false,

    /**
     * <embed>태그 필터링을 설정합니다.
     */
    'editor.contentFilter.allowEmbed': false,

    /**
     * <object>태그 필터링을 설정합니다.
     */
    'editor.contentFilter.allowObject': false,

    /**
     * <script>태그 필터링을 설정합니다.
     */
    'editor.contentFilter.allowScript': false,

    /**
     * HTML태그의 event attribute 필터링을 설정합니다. ex) onclick
     */
    'editor.contentFilter.allowEventAttribute': false,

    /**
     * <link>태그 필터링을 설정합니다.
     */
    'editor.contentFilter.allowLink': false,

    /**
     * htmlBuild시 옵션을 설정합니다.
     *  - peelOffDiv : 이 값이 true이면 불필요한 Div Tag를 벗겨냅니다.
     *  - alterDuplicateId : 이 값이 true이면 중복ID에 대한 알림을 표시합니다.
     *  - checkPreWrap : 이전에 에디터를 통해 저장된 pre-wrap속성의 문단을 처리하기위한 flag입니다.
     *                   이 값이 true인 경우 se-contents 하위 p에 pre-wrap속성이 하나라도 있을 경우 검사합니다.
     *  - customTagToDiv : 이 값이 true이면 Custom Tag를 Div Tag로 변환합니다. false 이면 customTag를 SEContainer Tag로 감싸서 표시합니다.
     *  - remainComment : 이 값이 true이면 html 코드에 있는 주석을 모델에 남겨둡니다.
     *  - remainNoneNode : 이 값이 true이면 display: none인 node를 남겨둡니다.
     */
    'editor.buildOption.html': {
        'peelOffDiv': false,
        'alertDuplicateId': true,
        'checkPreWrap': false,
        'customTagToDiv': false,
        'remainComment': false,
        'remainNoneNode': false
    },

    /**
     * 편집 가이드 표시 여부를 설정합니다.
     */
    'editor.guide': false,

    /**
     * 에디터 표 핸들을 사용할지 여부를 설정합니다.
     */
    'editor.table.handle': true,

    /**
     * 에디터 레이어의 핸들을 사용할지 여부를 설정합니다.
     */
    'editor.div.handle': true,

    /**
     * 에디터 자동링크 사용 여부를 설정합니다.
     */
    'editor.autoLink': true,

    /**
     * 에디터 자동링크에 target 값을 설정합니다.
     */
    'editor.autoLink.defaultTarget': '_blank',

    /**
     * '*, -, #, 1. + space'를 사용하여 글머리 기호/번호를 삽입하는 기능의 사용 여부를 설정합니다.
     */
    'editor.autoList': true,

    /**
     * 일반 글머리(HTML List) 사용 여부를 설정합니다.
     */
    'editor.useHTMLList': false,

    /**
     * 커스텀 글머리를 설정합니다.
     * 9레벨 까지 설정이 가능합니다.
     * 9레벨 이후로 설정된 글머리는 표현되지 않습니다.
     * ex) [
                { format: 'decimal' },
                { format: 'bullet', levelText: '□' },
                { format: 'bullet', levelText: '♧' },
                { format: 'decimalEnclosedCircle' },
                ...
            ]
     */
    'editor.list.customList': [],

    /**
     * 글머리번호의 타입을 설정합니다.
     */
    'editor.list.numberedListItems': ['decimal', 'decimalEnclosedCircle', 'decimalParentheses', 'upperLetter', 'lowerLetter', 'upperRoman', 'lowerRoman', 'ganada', 'chosung'],

    /**
     * 다단계글머리의 타입을 설정합니다.
     * multi_1 : 1.
     *               1.1
     *                   1.1.1
     * multi_2 : 1.
     *           1.1
     *           1.1.1
     * multi_3 : 1
     *           1-1
     *           1-1-1
     * multi_4 : (1)
     *               (1.1)
     *                   (1.1.1)
     * multi_5 : (1)
     *           (1.1)
     *           (1.1.1)
     */
    'editor.list.multiLevelListItems': ['none', 'multi_1', 'multi_2', 'multi_3', 'multi_4', 'multi_5'],

    /**
     * 도움말 기능 실행시 연결할 URL을 설정합니다.
     * ex) 'https://synapeditor.com/docs'
     */
    'editor.help.url': '',


    /*
     * 객체 회전시 shift키로 조절할 각도값을 설정합니다.
     */
    'editor.edit.rotate.step': 15,

    /**
     * 알림창이 자동으로 사라지기(fadeout) 전 표시되는 시간을 밀리초(ms) 단위로 설정합니다.
     */
    'editor.notification.fadeout': 3000,

    /**
     * 라이선스 만료 알림 메시지가 나타나는 일수(day)를 설정합니다.
     */
    'editor.notification.license.showDays': 20,

    /**
     * 알림창이 노출되는 레벨을 설정합니다. (error, warning, info 세 가지 레벨 중 선택)
     */
    'editor.notification.show.level': ['error', 'warning', 'info'],

    /**
     * 반응형 보기 버튼의 아이템을 설정합니다.
     * - iconName: 아이콘의 이름을 설정합니다. ('desktop', 'mobile', 'tablet', ..)
     * - message: 메세지를 설정합니다. 설정한 값이 메세지 키로 등록되어 있으면 등록된 메세지를 보여줍니다.
     * - size: 크기를 설정합니다. ({ width: {Number}, height: {Number} })
     */
    'editor.responsive.items': [
        { 'iconName': 'mobile', 'message': 'message.label.mobile', 'size': { 'width': 412, 'height': 846 } },
        { 'iconName': 'tablet', 'message': 'message.label.tablet', 'size': { 'width': 768, 'height': 1024 } }
    ],

    /**
     * 반응형 편집을 사용할지 여부입니다. (기본값 false)
     * true로 설정하게 되면 이미지/비디오 속성에서 반응형 여부를 체크할 수 있게됩니다.
     */
    'editor.responsive.use': false,

    /**
     * 이미지, 동영상 삽입 시 반응형 편집을 기본으로 사용할지 여부입니다. (기본값 false)
     * true로 설정하게 되면 이미지/비디오 속성에서 반응형 여부가 기본으로 체크되어 있습니다.
     */
    'editor.responsive.default.use': false,

    /**
     * 표 삽입시 px형태로 삽입할지를 설정합니다.
     * 값이 false일 경우 표의 너비가 "%"로 삽입됩니다.
     */
    'editor.table.defaultWidthUnit.px': false,

    /**
     * 이벤트 등록을 일정시간 지연시킵니다.
     */
    'editor.attachEvent.time': 0,

    /**
     * Alt + , 단축키를 실행해 에디터에서 포커스가 제거되었을 때,
     * 에디터 위쪽으로 포커스할 대상 Element가 있다면 Selector를 설정합니다.
     */
    'editor.removeFocus.prev.selector': '',

    /**
     * Alt + . 단축키를 실행해 에디터에서 포커스가 제거되었을 때,
     * 에디터 아래쪽으로 포커스할 대상 Element가 있다면 Selector를 설정합니다.
     */
    'editor.removeFocus.next.selector': '',

    /**
     * 접근성 - 편집과 관련된 보조 메세지 사용을 설정합니다.
     */
    'editor.accessibility.assistiveMessage': false,

    /**
     * 바로 삽입 기능을 사용할지 여부를 설정합니다.
     */
    'editor.quickInsert.show': false,

    /**
     * 바로 삽입에 보여질 컴포넌트를 설정합니다.
     */
    'editor.quickInsert': ['directInsertImage', 'directInsertVideo', 'directInsertTable', 'directBulletList', 'directNumberedList'],

    /**
     * td에 width를 적용할지 여부를 설정합니다.
     */
    'editor.table.applyCellWidth': false,

    /**
     * 외부 컨테이너가 위치할 Element를 찾는 Selector를 설정합니다.
     */
    'editor.external.container.selector': ''
};