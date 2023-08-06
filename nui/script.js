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
            $('#bodyTable').append('<td colspan="5" style="text-align: center; margin-top: 64px">No refunds found!</p>')
        }
        for (var i = 0; i < item.data.length; i++) {
            let itemsString = '';
            item.data[i].items.forEach(element => {
                itemsString += element[1] + 'x ' + element[0] + '; ';
            });
            newRows += "<tr><td>" + item.data[i].identifier +
                "</td><td>" + item.data[i].count +
                "</td><td>" + itemsString +
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
    if (values == "" || reason == "") return;
    if (amount == "") {
        amount = "0"
    }
    $.post(
        "https://ps_refunds/submit",
        JSON.stringify({
            values: values,
            amount: amount,
            reason: reason,
            items: itemsToGive
        })
    );
}

var itemsToGive = []

var inputItems = document.getElementById("items")

function additem(e) {
    var keycode;
    if (window.event)
        keycode = window.event.keyCode;
    else if (e)
        keycode = e.which;
    if (keycode === 13 && e.value != "") {

        $.post(
            "https://ps_refunds/checkvaliditem",
            JSON.stringify({
                item: e.value,
            })
        );

        var count = document.querySelector('#itemsCount').value;
        if (count === "") {
            count = 1;
        }
        var itemlist = document.getElementById("itemList")
        let div = document.createElement("div")
        itemsToGive.push([e.value, count])
        div.classList.add("item")
        div.id = e.value
        console.log("index: " + (itemsToGive.length - 1))
        div.setAttribute("index", (itemsToGive.length - 1))
        div.innerHTML = e.value + " (" + count + ")" + " <a onclick=\"removeItem('" + e.value + "')\">❌</a>"
        itemlist.appendChild(div)
        e.value = ""


        console.log(itemsToGive)
    }
}

function removeItem(item) {
    var itemlist = document.getElementById("itemList")
    var index = document.getElementById(item).getAttribute("index")
    console.log("index: " + index)
    itemsToGive[index] = null
    itemlist.removeChild(document.getElementById(item))
    console.log(itemsToGive)
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