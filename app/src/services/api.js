import axios from 'axios';

const api = axios.create({
    baseURL: 'http://200.98.81.201:40160/rest'
});


export default api;