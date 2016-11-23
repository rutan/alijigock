(function () {
    var app = new Vue({
        el: '#app',
        data: {
            mode: 'loading',
            status: 'none',
            messageStart: '',
            messageTraitor: ''
        },
        mounted: function () {
            var self = this;
            fetch('/settings.json', {
                credentials: 'include'
            })
                .then(function (res) {
                    return res.json();
                })
                .then(function (json) {
                    self.mode = 'setting';
                    self.messageStart = json.start;
                    self.messageTraitor = json.traitor;
                })
                .catch(function () {
                    self.mode = 'login';
                });
        },
        methods: {
            onClickSave: function (e) {
                e.preventDefault();
                var self = this;
                self.status = 'loading';

                var data = new FormData();
                data.append('start', self.messageStart);
                data.append('traitor', self.messageTraitor);

                fetch('/settings.json', {
                    method: 'post',
                    credentials: 'include',
                    headers: {
                        'X-From': location.href
                    },
                    body: data
                })
                    .then(function (resp) {
                        if (!resp.ok) throw 'reponse error';
                        self.status = 'ok';
                    })
                    .catch(function () {
                        self.status = 'error';
                    });
            }
        }
    });
})();
