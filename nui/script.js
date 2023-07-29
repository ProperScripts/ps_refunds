var item = null;

window.addEventListener('message', function (event) {
    item = event.data;
    //console.log(event.data)
    //console.log(JSON.stringify(event.data))
    if (item.showUI) {
        $('.container-mainscreen').show();
        document.querySelector('#bodyTable').innerHTML = '<tr id="heading"></tr>';
        //$('#bodyTable').remove();
        var newRows = "";

        if (item.data.length == 0) {
            $('#bodyTable').empty()
            $('#bodyTable').append('<td colspan="4" style="text-align: center; margin-top: 64px">No refunds found!</p>')
        }
        for (var i = 0; i < item.data.length; i++) {
            newRows += "<tr><td>" + item.data[i].identifier +
                "</td><td>" + item.data[i].count +
                "</td><td>" + item.data[i].reason +
                "</td><td>" + "<button type='button' onclick='removeIndex(" + i + ");' class='btn btn-secondary btn-sm'>Remove</button>" +
                "</td></tr>";
        }
        $("#heading").after(newRows);

        var selector = document.getElementById('playerselector');
        selector.options.length = 0;
        for (var i = 0; i < item.onlinePlayers.length; i++) {
            var option = this.document.createElement('option');
            option.text = item.onlinePlayers[i];
            selector.add(option);
        }


    } else {
        $('.container-mainscreen').hide();
    }
});

function removeIndex(index) {
    $.post(
        "https://ps_refunds/remove",
        JSON.stringify({
            index: index
        })
    );
}

let closeBtn = document.querySelector('#close-main-btn');
closeBtn.onclick = function () {
    $('.container-mainscreen').hide();
    $.post(
        "https://ps_refunds/close",
        JSON.stringify({})
    );
}


let submitButton = document.querySelector('#submit');
submitButton.onclick = function () {
    var values = $('#playerselector').val();
    var amount = $('#amount').val();
    var reason = $('#reason').val();
    if (values.length < 1 || amount == "" || reason == "") return;
    $.post(
        "https://ps_refunds/submit",
        JSON.stringify({
            values: values,
            amount: amount,
            reason: reason
        })
    );
}

function loadPlayers(AllPlayers) {
    var selector = document.getElementById('playerselector');
    selector.options.length = 0;
    if (AllPlayers) {
        for (var i = 0; i < item.allPlayers.length; i++) {
            var option = this.document.createElement('option');
            option.text = item.allPlayers[i];
            selector.add(option);
        }
    } else {
        for (var i = 0; i < item.onlinePlayers.length; i++) {
            var option = this.document.createElement('option');
            option.text = item.onlinePlayers[i];
            selector.add(option);
        }
    }
}

var checkbox = document.querySelector('#showAllPlayers');
checkbox.addEventListener('change', function () {
    if (this.checked) {
        loadPlayers(true)
    } else {
        loadPlayers(false)
    }
})