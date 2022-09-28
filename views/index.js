const index = "http://127.0.0.1:8000/geniepackagemanager";
const packageManagerBaseUrl = "http://127.0.0.1:8000/geniepackagemanager/api/v1/"

const {
    createApp
} = Vue

createApp({
    data() {
        return {
            results: {}
        }
    },
    methods: {
        AddPackage(packageName) {
            console.log(packageName);

            axios.post(packageManagerBaseUrl+packageName+"add").then(response => {
                console.log(response);
            })
        },
        RemovePackage(packageName) {
            console.log(packageName);

            axios.post(api+packageName+"remove").then(response => {
                console.log(response);
            })
        }
    },
    mounted() {
        axios.get(index).then(response => {
            this.results = response.data
        })
    }
}).mount('#app')