const index = "http://127.0.0.1:8000/geniepackagemanager";
const packageManagerBaseUrl = "http://127.0.0.1:8000/geniepackagemanager/api/v1/"

const {
    createApp
} = Vue

createApp({
    data() {
        return {
            results: {},
            toAddPackage: "",
            dev: false
        }
    },
    methods: {
        addPackage() {
            if (this.dev == false) {
                axios.post(packageManagerBaseUrl+this.toAddPackage+"/add").then(response => {
                    console.log(response);
                    window.location.reload();
                })
            }
            else {
                axios.post(packageManagerBaseUrl+this.toAddPackage+"/dev").then(response => {
                    console.log(response);
                    window.location.reload();
                })
            }
            
        },
        removePackage(packageName) {
            if(confirm('are you sure you want to update ' + packageName + '?'))
                axios.post(packageManagerBaseUrl+packageName+"/remove").then(response => {
                    console.log(response);
                    window.location.reload();
                })
        },
        updatePackage(packageName) {
            if(confirm('are you sure you want to remove ' + packageName + '?'))
                axios.post(packageManagerBaseUrl+packageName+"/update").then(response => {
                    console.log(response);
                    window.location.reload();
                })
        },
        // storePackageName(event) {
        //     this.toAddPackage = event.target.value;
        // }
    },
    mounted() {
        axios.get(index).then(response => {
            this.results = response.data
        })

    }
}).mount('#app')