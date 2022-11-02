/** 
Calcular sólo el precio bruto de un pedido, es decir, 
sin tener en cuenta el cliente. 
>> unPedido.precioBruto()

Determinar el costo real de envío de un pedido para un cliente.
>> unPedido.costoRealEnvio(unCliente)

Dado un pedido, saber cual es el valor de envío que debe abonar un cliente 
determinado.
>> unPedido.valorEnvio(unCliente)


Agregar a un pedido una cantidad de un producto. El pedido puede ya incluir el 
producto anteriormente, en cuyo caso sólo debe incrementarse la cantidad del 
ítem correspondiente.
>> unPedido.agregarProducto(producto, cantidad)


Dado un pedido, hacer que un cliente realice una compra. 
Una compra está compuesta por un pedido, además el valor del envío que debe 
abonar y la fecha actual. Para que la compra se pueda realizar, debe cumplirse 
que el local tenga todos los productos.
>> unCliente.realizarCompra(unPedido)

Conocer la compra más cara realizada por un cliente.
>> cliente.compraMasCara()


Saber el monto total ahorrado por un cliente, teniendo en cuenta lo que pagó 
el cliente por envíos respecto al total de costo real de envío para cada pedido.
>> cliente.totalAhorrado()


Conocer, para un cliente, el producto...
- mas caro
- mas comprado
>> cliente.productoMasCaro()
>> cliente.productoMasComprado()
*/

class Pedido {
	// en java: var static topeMaxEnvio
	const local
	const property items = #{} //o bien: new Dictionary()
	
	/** Punto 1 */
	method precioBruto() = items.sum{ item => item.precio() }
	
	/** Punto 2.a */
	method costoRealEnvio(unCliente) {
		const cantidadCuadras = calculadorDeCuadras.cuadras(local, unCliente)
		return pedido.topeMaxEnvio().
			min(cantidadCuadras * pedido.costoPorCuadra())
	} 
		
	/** Punto 2.b */
	method valorEnvio(unCliente) = 
		unCliente.valorEnvio(self.costoRealEnvio(unCliente))
		
	/** Punto 3.a */
	method agregarProducto(unProducto, unaCantidad) {
		const item = items.findOrDefault({ item => item.contiene(unProducto) }, 
									new Item(producto=unProducto))
		items.add(item)
		item.agregarCantidad(unaCantidad)					
	}
	
	method validar() {
		local.validarProductos(self.productos())
	}
	
	method productos() = items.map{ item => item.producto() }
	
}

object pedido { // Object Companion
	var property topeMaxEnvio = 300
	var property costoPorCuadra = 15
}

object calculadorDeCuadras {
	method cuadras(local, cliente) = 10
}

class Item {
	
	const property producto
	var cantidad = 0
	
	method precio() = producto.precio() * cantidad
	
	method contiene(unProducto) = unProducto == producto
	
	method agregarCantidad(unaCantidad) {
		cantidad += unaCantidad
	}
	
	method precioProducto() = producto.precio()
	
	override method ==(otroItem) = producto == otroItem.producto()
}

class Producto {
	const property precio
	
	
}


class Local {
	const productos = #{}	
	
	method validarProductos(unosProductos){
		if (not unosProductos.all{ producto => productos.contains(producto) })
			throw new DomainException(message = "El local no tiene todos los productos") 
	}
}


class Compra {
	const property pedido
	const property fecha
	const property valorEnvio
	
	method precio() = pedido.precioBruto() + valorEnvio 
	
	method ahorro(unCliente) = pedido.costoRealEnvio(unCliente) - valorEnvio
	
	method productos() = pedido.productos()
	
	method items() = pedido.items()
}

class Cliente {
	
	var tipoCliente
	const property compras = []
	
	method valorEnvio(costoRealEnvio) = 
		tipoCliente.valorEnvio(costoRealEnvio)
		
	/** Punto 3.b */ 
	method realizarCompra(unPedido) {
		unPedido.validar()
		const compra = new Compra(pedido = unPedido,
								 fecha = new Date(),
								 valorEnvio = unPedido.valorEnvio(self))
		compras.add(compra)
		tipoCliente.compraRealizada()
	}
	
	method cantidadDeCompras() = compras.size()
	
	/** Punto 4 */
	method compraMasCara() = compras.max{compra => compra.precio()}
	
	/** Punto 5 */
	method totalAhorrado() = compras.sum{compra => compra.ahorro(self) }
	
	/** Punto 6 */
	method productoMasCaro() = compras.flatMap{ compra => compra.productos()}.
											max{ producto => producto.precio()}
											
	method productoMasComprado() = compras.flatMap{ compra => compra.items()}.
											max{ item => item.cantidad()}.
											producto()
	
	method productoMasCaro2() = self.productoMayor( {item => item.precioProducto()} )
	method productoMasComprado2() = self.productoMayor( {item => item.cantidad()} )
											
	method productoMayor(bloqueItem) = compras.flatMap{ compra => compra.items()}.
											max{ bloqueItem }.
											producto
}

object clienteComun {
	
	method compraRealizada() {}
	
	method valorEnvio(costoRealEnvio) = costoRealEnvio
}

object clienteSilver {
	
	method compraRealizada() {}

	method valorEnvio(costoRealEnvio) = costoRealEnvio * 0.5
}

class ClienteGold {
	
	var cantidadCompras = 0
	
	method compraRealizada() {
		cantidadCompras += 1
	}

	method valorEnvio(costoRealEnvio) {
		if (cantidadCompras > 0 && 
			cantidadCompras % clienteGold.cantidadDeComprasPorPromo() == 0) return 0
		else return costoRealEnvio * 0.1
	}
	
}

object clienteGold { // Object Companion
	var property cantidadDeComprasPorPromo = 5
}