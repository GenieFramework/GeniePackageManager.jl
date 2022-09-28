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
            axios.post(packageManagerBaseUrl+packageName+"/add").then(response => {
                console.log(response);
            })
        },
        RemovePackage(packageName) {
            axios.post(packageManagerBaseUrl+packageName+"/remove").then(response => {
                console.log(response);
            })
        },
        UpdatePackage(packageName) {
            axios.post(packageManagerBaseUrl+packageName+"/update").then(response => {
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