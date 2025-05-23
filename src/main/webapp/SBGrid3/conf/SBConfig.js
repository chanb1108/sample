/**
 * Resource관련 설정
 */
globalThis.customResource = {
  // emptyMessage: '조회조건에 해당하는 데이터가 없습니다.',

  // /***Menu 관련 ******/
  // menu_column: '컬럼',
  // menu_fiexCol: '고정(열)',
  // menu_header: '좌측',
  // menu_body: '중앙', 
  // menu_columnSticky: '스티키',
  // menu_tail: '우측',
  // menu_asc: '오름차순',
  // menu_desc: '내림차순',
  // menu_reset: '정렬 취소',
  // menu_copy: '복사',
  // menu_cut: '자르기',
  // menu_paste: '붙여넣기',
  // menu_undo: '되돌리기',
  // menu_redo: '재실행',
  // menu_addRow: '행 추가(맨 아래)',
  // menu_addTop: '행 추가(맨 위)',
  // menu_insertRow: '행 추가(위)',
  // menu_appendRow: '행 추가(아래)',
  // menu_deleteRow: '행 삭제',
  // menu_sticky: '행 고정',
  // menu_sticky_cancel: '행 고정(취소)',
  // menu_edit: '편집',
  // menu_cancel: '취소',
  // menu_excel: '엑셀',
  // menu_submit_button: '확인',
  // menu_cancel_button: '취소',

  // /**Tool 관련 */
  // tool_copy: '복사',
  // tool_edit: '편집',
  // tool_update: '수정', 
  // tool_cancel: '취소',
  // tool_save: '저장',
  // tool_refresh: '새로고침',
  // tool_reload: '다시로드',
  // tool_undo: '되돌리기',
  // tool_redo: '재실행',
  // tool_add: '행 추가(자식)',
  // tool_addRow: '행 추가(맨 아래)',
  // tool_addTop: '행 추가(맨 위)',
  // tool_insertRow: '행 추가(위)',
  // tool_appendRow: '행 추가(아래)',
  // tool_deleteRow: '행 삭제',
  // tool_undeleteRow: '삭제 취소',
  // tool_excel: '엑셀 다운로드',
  // tool_csv: 'csv 다운로드',
  // tool_search: '찾기',
  // tool_pagerCombo_delimiter: '/',
  // tool_pagerSizes: '',
  // tool_pagerCombo_alert: '페이지 범위를 벗어났습니다.',

  // /**filter 관련 */
  // filter_isLessThan: '다음 보다 작음',
  // filter_isLessThanOrEqualTo: '다음 보다 작거나 같음',
  // filter_isEqualTo: '다음과 같음',
  // filter_isNotEqualTo: '다음과 같지 않음',
  // filter_isGreaterThan: '다음 보다 큼',
  // filter_isGreaterThanOrEqualTo: '다음 보다 크거나 같음',
  // filter_in: '다음을 포함',
  // filter_notIn: '다음을 포함하지 않음',
  // filter_fromTo: '다음 범위에 포함',
  // filter_notFromTo: '다음 범위에 포함되지 않음',
  // filter_startsWith: '다음으로 시작',
  // filter_notStartsWith: '다음으로 시작되지 않음',
  // filter_endsWith: '다음으로 끝남',
  // filter_notEndsWith: '다음으로 끝나지 않음',
  // filter_contains: '문자열에 다음을 포함',
  // filter_notContains: '문자열에 다음을 포함하지 않음',
  // filter_isNull: 'Null과 같음',
  // filter_isNotNull: 'Null이 아님',
  // filter_isEmpty: '비었음',
  // filter_isNotEmpty: '비어있지 않음',
  // filter_isNullOrEmpty: 'Null이거나 비었음',
  // filter_isNotNullOrEmpty: 'Null이 아니거나 비어있지 않음',
  // filter_all: 'all',
  // filter_and: 'and', 
  // filter_or: 'or',
  // filter_none: 'none',
  // filter_submit: '적용',
  // filter_clear: '해제',
  // filter_placeholder: 'enter시 필터링이 반영됩니다.',
  // filter_total: 'all',
  // filter_selected: 'checked',

  // /**filter 관련 placeholder */
  // filter_placeholder_text: '',
  // filter_placeholder_number: '',
  // filter_placeholder_date: '',
  // filter_emptyMessage: '값이 없습니다',

  // /**groupping 관련 */
  // group_groupZone: '이곳으로 컬럼의 헤더를 드롭하여 그룹핑 하세요',

  // /**combo 관련 */
  // select_all: '전체 선택',

  // /**search 관련 */
  // search_title: 'Search',
  // serach_caseSensitive: '대소문자 구분',
  // search_wholeWord: '전체 일치',
  // search_backward: '이전 검색',
  // search_find: '검색',
  // search_cancel: '닫기'
};


/**
 * Config관련 설정
 */
globalThis.customDefaultConfig = {
  // container: undefined,
  // height: undefined,
  // width: undefined,

  // theme: '',

  // editable: false,

  // pageable: false,

  /*defaultPageable: {
    pager: {
      numeric: true,
      previousNext: true,
      buttonCount: 10,
    },
    pagerCombo: {
      listCount: 5,
    },
    pageSizes: [10, 20, 30, 40, 50],
  }, */

  // sortable: 'none',
  // defaultSortable: 'rotate',

  // multiSort: false,
  // navigatable: false,
  /* defaultNavigatable: {
    tabToNextCell: { edit: false }
  }, */

  // resizable: false,
  /* defaultResizable: {
    mode : 'guideLine', 
    minWidth : 10, 
    autoFit: ['caption','data']
  }, */

  // reorderable: { row: undefined, column: undefined },
  // defaultReorderable: { row: true, column: true },

  // groupable: false,
  // filterable: false,
  // defaultFilterable: 'menu',

  // checkable: false,
  // undoable: true,
  // virtualRow: true,
  // virtualColumn: false,
  // fixedRows: true,
  // rowCss: undefined,
  // alternateCss: 2,
  // panels: ['hidden', 'title', 'tool', 'group', 'scroll', 'pager', 'status', 'loading'],
  // emptyTemplate: undefined,
  // detailTemplate: undefined,
  // detailOverflow: undefined,
  // detailInit: undefined,
  // toolBar: undefined,
  // titleBar: undefined,
  // groupBar: undefined,
  // pagerBar: undefined,
  // statusBar: undefined,
  // stickyHeader: false,
  // stickyFooter: false,
  // stickyRow: false,
  // stickyEdit: false,
  // stickyInsert: false,
  // stickyUpdate: false,
  // stickyDelete: false,
  // mergeRow: false,
  // mergeColumn: false,
  // selectable: false,
  // hover: false, 
  // groupAutoOpen: false, 
  // detailAutoOpen: false, 
  // rowHeaders: ['row', 'sticky', 'check', 'reorder', 'status', 'detail'],
  // showRowNo: true,
  // showSticky: false,
  // showStatus: false, 
  // showDetail: true, 
  // wheelDelta: 30,
  // contextMenu: false,
  // defaultContextMenu: ['clipboard', 'undo', 'redo', 'addRow'],
  // copyable: false,
  // defaultCopyable: { fill: false },

  // freezable: false,

  // captionHeight: 30,
  // rowHeight: 30,
  // maxRowHeight: 100,
  // headerHeight: 30,
  // footerHeight: 30,
  // filterHeight: 30,
  // groupHeight: 30,
  // detailHeight: 60,
  // maxDetailHeight: 300,
  // copyInsert: false,

  /* pagerOption: {
    numeric: true,
    previousNext: true,
    buttonCount: 10,
  }, */

  defaultColumn: {
    // align: 'center',
    // valign: 'center',
    // width: 100,
    // minWidth: 10,
    // maxWidth: 500,
    // sortable: 'rotate',
    // editable: true,
    // selectable: true,
    // groupable: true,
    // captionCheck: false,
    // visible :true, 
    // captionVisible: true,
    // skipPaste: false,
    // directApplyValue: false,
    // directApplyEdit: false,
    // groupTitle: undefined,
    // captionLayout: {
    //     left: ['check'],
    //     center: ['caption', 'sort', 'filter'],
    //     right: ['menu'],
    //     rightFlex: { flexGrow: 0 },
    //     leftFlex: { flexGrow: 0 },
    // },
    // captionMenu: false,
    /* defaultCaptionMenu: [
        'column',
        'fixedCol',
        'sort',
    ], */
    // contextMenu: false,
    // defaultContextMenu: [
    //     'clipboard',
    //     'undo',
    //     'redo',
    //     'sticky',
    //     'insertRow',
    //     'appendrow',
    //     'addRow',
    //     'deleteRow',
    //     'edit',
    //     'cancel',
    // ],
    // groups: undefined,
    // tree: undefined,
    // calc: undefined,
    // dropDownConfig: undefined,
    // validators: undefined,
    // mergeRow: undefined,
    // mergeColumn: undefined,
    // filter: undefined,
    // skipPaste: undefined,
  }
}