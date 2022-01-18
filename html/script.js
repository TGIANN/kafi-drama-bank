window.addEventListener('message', (event) => {
    if (event.data.type === 'open') {
        const data = event.data.data
        $("#name1").html(data.firstname + " " + data.lastname);
        $(".username2").html(data.firstname + " " + data.lastname);
        $("#mymoney").html(data.bank + ",00 $");
        $("#cardmoney").html(data.bank + ",00 $");
        $("#iban").html("•••• " + data.iban);
        $("#iban2").html("•••• " + data.iban);
        $("#profilepicture").css('background-image', 'url('+data.profilepicture+')')

        let banklogsontransferHtml = ""
        for (let i = 0; i < data.banklogsontransfer.length; i++) {
            banklogsontransferHtml += `
                <div class="son-transfer-alt-container">
                    <div class="image" style="background-image: url(`+data.banklogsontransfer[i].foto+`)"></div>
                    <div class="name-detail">
                        <p>`+data.banklogsontransfer[i].isim+`</p>
                    </div>
                    <div class="input">
                        <input id="`+data.banklogsontransfer[i].iban+`input" type="number" placeholder="00.00"><span>$</span>
                    </div>
                    <div class="button">
                        <button id="`+data.banklogsontransfer[i].iban+`" class="sontransferparagonder">Gönder</button>
                    </div>
                </div>
            `
        }
        $('#doldurknk').html(banklogsontransferHtml);

        let banklogHtml = ""
        for (let i = 0; i < data.banklog.length; i++) {
            if (data.banklog[i].iban === "BANK") {
                image = 'img/master-car.png'
            } else {
                image = data.banklog[i].profilepicture
            }
    
            banklogHtml += `
                <div class="islemler-container">
                    <div class="photo">
                        <div class="image" style="background-image: url(`+ image +`);"></div>
                    </div>
                    <div class="texts">
                        <div class="header">
                        <p>`+ data.banklog[i].sender +`</p>
                        </div>
                        <div class="detail">
                        <p>`+ data.banklog[i].action +`</p>
                        </div>
                    </div>
                    <div class="card-number">
                        <p>•••• `+ data.banklog[i].iban +`</p>
                    </div>
                    <div class="miktar">
                        <p style="color: #`+ data.banklog[i].color +`">`+ data.banklog[i].money +`,00 USD</p>
                    </div>
                </div>
            `
        }
        $('.islemler').html(banklogHtml);

        let billingHtml = ""
        for (let i = 0; i < data.billing.length; i++) {
            billingHtml += `
                <div id="`+data.billing[i].id+`" class="debt-container" style="border-bottom: 2px solid rgba(255, 255, 255, 0.178);">
                    <div class="image"></div>
                    <div class="text"><p>`+data.billing[i].label+`</p></div>
                    <div class="cdebt"><p>`+data.billing[i].amount+` $</p></div>
                    <div class="button"> <button id="`+data.billing[i].id+`" class="payinvoice">Öde</button></div>
                </div>
            `
        }
        $('#faturadoldur').html(billingHtml);
        $(".background").fadeIn()
    }
});

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESCAPE
        $(".background").fadeOut()
        $.post('https://kafi-bank/closeapp', JSON.stringify({}));
        break;
    }
});

$("#hzlcek100").click(function(){
    $.post('https://kafi-bank/cek', JSON.stringify({
        para: 100
    }));
});

$("#hzlcek500").click(function(){
    $.post('https://kafi-bank/cek', JSON.stringify({
        para: 500
    }));
});

$("#hzlcek1000").click(function(){
    $.post('https://kafi-bank/cek', JSON.stringify({
        para: 1000
    }));
});

$("#hzlyatir100").click(function(){
    $.post('https://kafi-bank/yatir', JSON.stringify({
        para: 100
    }));
});

$("#hzlyatir500").click(function(){
    $.post('https://kafi-bank/yatir', JSON.stringify({
        para: 500
    }));
});

$("#hzlyatir1000").click(function(){
    $.post('https://kafi-bank/yatir', JSON.stringify({
        para: 1000
    }));
});


$("#miktargircek").click(function(){
    var para = $("#withdrawcustominput").val()

    $.post('https://kafi-bank/cek', JSON.stringify({
        para: para
    }));

    $("#withdrawcustominput").val("")
});


$("#miktargityatir").click(function(){
    var para = $("#depositcustominput").val()

    $.post('https://kafi-bank/yatir', JSON.stringify({
        para: para
    }));

    $("#depositcustominput").val("")
});

$(".transfferyap").click(function() {
    $.post('https://kafi-bank/transfer', JSON.stringify({
            iban: $("#transferiban").val(),
            para: $("#transferpara").val()
        })
    );
    $("#transferiban").val("")
    $("#transferpara").val("")
}); 

$(document).on('click', '.payinvoice', function(event){
    $.post('https://kafi-bank/PayInvoice', JSON.stringify({
        invoiceId: this.id
    }));
});

$(".sontransferparagonder").click(function() {
    var thisid = this.id
   $.post('https://kafi-bank/transfer', JSON.stringify({
           iban: $("#"+this.id+"").val(),
           para: $("#"+this.id+"input").val()
       })
   );
   $("#"+thisid+"input").val("")
}); 