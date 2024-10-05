let CaptureKeys = false
let LastConfig = {}

window.addEventListener("message", function(event) {
    let data = event.data;

    switch (data.action) {
        case 'update':
            $('#postal').html(data.postal)
        break;
        case 'edit':
            $('#editable').show()
            CaptureKeys = true
        break;
        case 'sendConfig':
            LastConfig = data.config

            $('#opacity').val(LastConfig.opacity)
            $('#background').val(LastConfig.background)
            $('#text').val(LastConfig.text)
            $('#box_border').val(LastConfig.box_border)
            $('#box_padding').val(LastConfig.box_padding)
            $('#text_size').val(LastConfig.text_size)

            for (const key in data.config) {
                let value = data.config[key]
                changeSetting(key, value)
            }
        break;
        case 'show':
            $('#draggable').show()
        break;
        case 'hide':
            $('#draggable').hide()
        break;
        case 'close':
            close()
        break;
    }
});

$(document).ready(function() {
    $("#draggable").draggable({});

    $(document).on('keyup',function(evt) {
        if (CaptureKeys){
            if (evt.keyCode == 27) {
                close()
            }
        }
    });
});

function cancel(){
    for (const key in LastConfig) {
        let value = LastConfig[key]
        changeSetting(key, value)
    }
    close()
}

function save(){
    let drawable = $('#draggable').offset()
    $.post(`https://${GetParentResourceName()}/save`, JSON.stringify({
        x: drawable.left, 
        y: drawable.top,
        background: $('#background').val(),
        text: $('#text').val(),
        opacity: $('#opacity').val(),
        box_border: $('#box_border').val(),
        box_padding: $('#box_padding').val(),
        text_size: $('#text_size').val()
    }));
    close()
}

function changeSetting(name, value){
    switch (name) {
        case 'x':
            $("#draggable").css('left', value);
        break;
        case 'y':
            $("#draggable").css('top', value);
        break;
        case 'background':
        case 'opacity':
            let colour = hexToRgb($('#background').val())
            let opacity = $('#opacity').val()
            $('.drawable-container').css('background-color', `rgba(${colour.r},${colour.g},${colour.b},${opacity})`)
        break;
        case 'text':
            $('#postal').css('color', value)
        break;
        case 'text_size':
            $('#postal').css('font-size', value+'px')
        break;
        case 'box_border':
            $('.drawable-container').css('border-radius', value+'px')
        break;
        case 'box_padding':
            $('.drawable-container').css('padding', value+'px')
        break;
    }
}

function close(){
    CaptureKeys = false
    $('#editable').hide()
    $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));
} 

function hexToRgb(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}