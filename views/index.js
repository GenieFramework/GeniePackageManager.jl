const index = "http://127.0.0.1:8000/geniepackagemanager";
const add = ""

const {
    createApp
} = Vue

createApp({
    data() {
        return {
            results: {}
        }
    },
    mounted() {
        axios.get(index).then(response => {
            this.results = response.data
        })
    }
}).mount('#app')