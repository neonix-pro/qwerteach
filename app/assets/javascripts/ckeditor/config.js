if (typeof(CKEDITOR) != 'undefined') {

    CKEDITOR.editorConfig = function( config ) {
        config.language = "fr";
        config.width = '100%';
        config.height = '33em';
        config.toolbar_Pure = [
            {name: 'clipboard', items: ['Cut', 'Copy', 'Paste', '-', 'Undo', 'Redo']},
            {
                name: 'basicstyles',
                items: ['Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', 'Link', '-', 'RemoveFormat']
            },
            {
                name: 'paragraph',
                items: ['BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', '-',
                    'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock']
            },
            {name: 'styles', items: ['TextColor', 'BGColor', 'Font', 'FontSize', 'PageBreak']},
            {name: 'insert', items: ['Smiley']}
        ];
        config.toolbar = 'Pure';
    }
}
